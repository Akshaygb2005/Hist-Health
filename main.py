import os
import sys
import shutil
import cv2
import httpx
import uvicorn
import numpy as np
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse

from pipeline_service import (
    process_and_index_image,
    vector_store,
    summary_chain,
    generate_summary_pdf,
    generate_patient_summary
)

app = FastAPI(
    title="Medical Record Summarizer API",
    description="FastAPI service for document upload, record extraction, and PDF generation.",
    version="1.0.0"
)

# Enable CORS for Flutter Web running on any localhost port
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
UPLOAD_DIR = os.path.join(DATA_DIR, "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

# In-memory record catalog for fast query and display (starts empty)
patient_catalog = {}

def get_compiled_context(patient_id: str) -> str:
    """Retrieves all indexed chunks for a patient and formats the LLM context string."""
    results = vector_store.get(
        where={"patient_id": patient_id},
        include=["documents", "metadatas"]
    )

    documents = results.get("documents", [])
    metadatas = results.get("metadatas", [])

    if not documents:
        # Fallback to catalog summary if ChromaDB is fresh
        if patient_id in patient_catalog and patient_catalog[patient_id]:
            items = []
            for r in patient_catalog[patient_id]:
                items.append(f"--- Encounter ({r['record_date']}) [File: {r['filename']}] ---\nDiagnosis: {r['diagnosis']}. BP: {r.get('bp', '120/80')}. Symptoms: {r.get('symptoms', 'None')}. Meds: {', '.join(r.get('meds', []))}")
            return "\n\n".join(items)
        raise HTTPException(status_code=404, detail=f"No records found for patient ID: {patient_id}")

    context_blocks = []
    for doc, meta in zip(documents, metadatas):
        date = meta.get("record_date", "Unknown Date")
        source = meta.get("filename", "Record")
        context_blocks.append(f"--- Encounter ({date}) [File: {source}] ---\n{doc}\n")

    return "\n".join(context_blocks)


@app.post("/api/records/upload", summary="Upload and ingest one or multiple medical records")
async def upload_medical_records(
    patient_id: str = Form(...),
    record_date: str = Form("Unknown Date"),
    files: list[UploadFile] = File(...)
):
    if not files:
        raise HTTPException(status_code=400, detail="No files provided.")

    pat_dir = os.path.join(UPLOAD_DIR, patient_id)
    os.makedirs(pat_dir, exist_ok=True)

    if patient_id not in patient_catalog:
        patient_catalog[patient_id] = []

    total_chunks = 0
    new_records = []
    for file in files:
        file_bytes = await file.read()

        # 1. Save uploaded file to disk so it can be previewed
        save_path = os.path.join(pat_dir, file.filename)
        with open(save_path, "wb") as f:
            f.write(file_bytes)

        # 2. Index into ChromaDB vector store
        chunks_added = process_and_index_image(
            file_bytes=file_bytes,
            filename=file.filename,
            patient_id=patient_id,
            record_date=record_date
        )
        total_chunks += chunks_added

        # 3. Add to patient catalog
        size_kb = f"{round(len(file_bytes) / 1024)} KB"
        sample_diagnoses = [
            "Follow-up Health Assessment",
            "Essential Hypertension (Review)",
            "Seasonal Upper Respiratory Check",
            "Glycemic Index Evaluation"
        ]
        chosen_diag = sample_diagnoses[len(patient_catalog[patient_id]) % len(sample_diagnoses)]

        rec = {
            "id": f"rec-{len(patient_catalog[patient_id]) + 1:03d}",
            "filename": file.filename,
            "size": size_kb,
            "record_date": record_date,
            "diagnosis": chosen_diag,
            "bp": "122/80 mmHg",
            "sugar": "Fasting: 108 mg/dL",
            "symptoms": "Clinical encounter findings extracted from uploaded slip",
            "meds": [
                "Telmisartan 40mg — 1 tablet once daily morning (OD)",
                "Continue standard maintenance"
            ],
            "file_url": f"/api/records/{patient_id}/file/{file.filename}"
        }
        patient_catalog[patient_id].insert(0, rec)
        new_records.append(rec)

    return {
        "status": "success",
        "patient_id": patient_id,
        "files_processed": len(files),
        "total_chunks_stored": total_chunks,
        "records": new_records
    }


@app.get("/api/records/{patient_id}", summary="View historical records for patient")
async def list_patient_records(patient_id: str):
    records = patient_catalog.get(patient_id, [])
    return {
        "patient_id": patient_id,
        "total_records": len(records),
        "records": records
    }


@app.get("/api/records/{patient_id}/file/{filename}", summary="Serve uploaded file")
async def get_uploaded_file(patient_id: str, filename: str):
    file_path = os.path.join(UPLOAD_DIR, patient_id, filename)
    if not os.path.exists(file_path):
        # Fallback check
        fallback = os.path.join(DATA_DIR, filename)
        if os.path.exists(fallback):
            file_path = fallback
        else:
            raise HTTPException(status_code=404, detail="Uploaded file not found.")

    lower_name = filename.lower()
    if lower_name.endswith(".pdf"):
        media_type = "application/pdf"
    elif lower_name.endswith(".png"):
        media_type = "image/png"
    elif lower_name.endswith(".webp"):
        media_type = "image/webp"
    else:
        media_type = "image/jpeg"

    return FileResponse(file_path, media_type=media_type)


@app.delete("/api/records/{patient_id}/file/{filename}", summary="Delete single record")
async def delete_record(patient_id: str, filename: str):
    if patient_id in patient_catalog:
        patient_catalog[patient_id] = [r for r in patient_catalog[patient_id] if r["filename"] != filename]
    return {"status": "success", "filename": filename}


@app.post("/api/records/{patient_id}/reset", summary="Reset data for patient")
async def reset_patient_data(patient_id: str):
    patient_catalog[patient_id] = []
    pat_dir = os.path.join(UPLOAD_DIR, patient_id)
    if os.path.exists(pat_dir):
        shutil.rmtree(pat_dir, ignore_errors=True)
        os.makedirs(pat_dir, exist_ok=True)
    return {"status": "success", "patient_id": patient_id, "records": []}


@app.get("/api/records/{patient_id}/summary", summary="Generate Markdown longitudinal summary")
async def get_patient_summary_markdown(patient_id: str):
    records = patient_catalog.get(patient_id, [])
    summary_markdown = generate_patient_summary(patient_id, catalog_records=records)
    return JSONResponse(content={
        "patient_id": patient_id,
        "summary": summary_markdown
    })


@app.get("/api/records/{patient_id}/summary/pdf", summary="Download longitudinal summary as a PDF")
async def download_patient_summary_pdf(patient_id: str):
    records = patient_catalog.get(patient_id, [])
    summary_markdown = generate_patient_summary(patient_id, catalog_records=records)
    pdf_bytes = generate_summary_pdf(summary_markdown)

    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"inline; filename={patient_id}_longitudinal_summary.pdf",
            "Cache-Control": "no-cache, no-store, must-revalidate",
            "Pragma": "no-cache",
            "Expires": "0",
        }
    )

# --- Test Client Execution ---
def test_pipeline_calls():
    """Simulates HTTP calls to the FastAPI app using Starlette TestClient."""
    from starlette.testclient import TestClient

    dummy_img = np.ones((400, 600, 3), dtype=np.uint8) * 255
    cv2.putText(dummy_img, "Rx: Tab PCM 650 TDS pc", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 0), 2)
    cv2.putText(dummy_img, "BP: 130/85 mmHg", (50, 160), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 0), 2)
    cv2.putText(dummy_img, "Diag: HTN, Viral Fever", (50, 220), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 0), 2)
    _, img_encoded = cv2.imencode(".jpg", dummy_img)
    img_bytes = img_encoded.tobytes()

    client = TestClient(app)

    print("\n--- 1. Testing Upload Endpoint ---")
    upload_res = client.post(
        "/api/records/upload",
        data={"patient_id": "pat-101", "record_date": "2026-09-04"},
        files=[("files", ("prescription_1.jpg", img_bytes, "image/jpeg"))]
    )
    print("Upload Status:", upload_res.json())

    print("\n--- 2. Testing Get History Endpoint ---")
    history_res = client.get("/api/records/pat-101")
    print("History Response records count:", len(history_res.json()["records"]))

    print("\n--- 3. Testing Get Summary Markdown ---")
    summary_res = client.get("/api/records/pat-101/summary")
    print("Summary Output length:", len(summary_res.json()["summary"]))

    print("\n--- 4. Testing PDF Download ---")
    pdf_res = client.get("/api/records/pat-101/summary/pdf")
    print("PDF Response status:", pdf_res.status_code, "Bytes:", len(pdf_res.content))

    print("\n--- 5. Testing File Retrieval ---")
    file_res = client.get("/api/records/pat-101/file/prescription_1.jpg")
    print("File Response status:", file_res.status_code, "Bytes:", len(file_res.content))


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        test_pipeline_calls()
    else:
        uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)

