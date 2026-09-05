# HistHealth: Longitudinal Medical Record Summarizer & RAG Engine

An offline-capable, privacy-first clinical intelligence system that ingests scanned prescription slips and medical reports, expands cryptic Latin abbreviations and medical shorthand, indexes multi-visit patient records into ChromaDB with strict patient isolation, and synthesizes chronological encounters into a unified longitudinal medical summary and downloadable PDF.

## 1. System Architecture

```
[Prescription / Lab Images (JPG/PNG)]
                  │
                  ▼
┌──────────────────────────────────────────────────────────┐
│ Step 1: Preprocessing & OCR Ingestion Layer               │
│ - OpenCV (Grayscale conversion + Adaptive Thresholding)   │
│ - Tesseract OCR engine (Character recognition)            │
└─────────────────────────┬──────────────────────────────────┘
                          │ (Raw OCR Text)
                          ▼
┌──────────────────────────────────────────────────────────┐
│ Step 2: Medical Normalization & Chunking Layer            │
│ - RecursiveCharacterTextSplitter (LangChain)              │
│ - Ollama LLM (`qwen2.5:3b`): Decodes Latin shorthand       │
│   (e.g., TDS -> 3 times a day, OD -> Once daily, pc)       │
│ - Corrects OCR misspellings & standardizes clinical terms  │
└─────────────────────────┬──────────────────────────────────┘
                          │ (Cleaned Chunks + Metadata)
                          ▼
┌──────────────────────────────────────────────────────────┐
│ Step 3: Embeddings & Vector Storage Layer                  │
│ - Ollama Embeddings (`mxbai-embed-large` or `bge-m3`)       │
│ - ChromaDB Persistent Vector Database                      │
│ - Strict Metadata Isolation:                                │
│   `{ patient_id, record_date, filename, chunk_index }`      │
└─────────────────────────┬──────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │ (On-Demand Longitudinal Query)│
          ▼                               ▼
┌────────────────────────────────┐ ┌──────────────────────────────────┐
│ Multi-Record Retrieval Layer    │ │ Multi-Record Synthesis Layer      │
│ - Pulls all chunks partitioned   │ │ - Consolidated condition grouping │
│   by `patient_id`                │ │ - Latest BP & Blood Sugar pickup  │
│ - Preserves encounter dates      │ │ - De-duplicated medication list   │
└────────────────────────────────┘ └──────────────┬───────────────────┘
                                                  │
                                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│ Delivery & Output Layer                                              │
│ - Standardized Markdown Clinical Summary                             │
│ - ReportLab Dynamic PDF Generation Engine                            │
│ - FastAPI REST API (`/api/records/upload`, `/summary/pdf`)           │
└─────────────────────────────────────────────────────────────────────┘
```

## 2. What This System Does

- **Optical Character Recognition (OCR) & Preprocessing:** Cleans noisy scanned images using adaptive thresholding and extracts raw text through Tesseract OCR.
- **Medical Shorthand Normalization:** Employs an LLM chain to translate Latin prescription codes into plain clinical English:
  - OD → Once daily
  - BD / BID → Twice daily
  - TDS / TID → Three times a day
  - SOS / PRN → As needed (in emergency/pain)
  - pc / ac → After meals / Before meals
  - HTN → Hypertension, DM2 → Type 2 Diabetes Mellitus
- **Chunking & Persistent Partitioning:** Splits text into chunks and stores them in ChromaDB with metadata partitions (`patient_id`) to prevent cross-patient data leakage.
- **Longitudinal Synthesis (Multi-Record Aggregation):** Rather than isolated per-visit summaries, it merges all stored encounters for a patient into a single, condition-centric health report.
- **PDF Export:** Converts the consolidated summary into a styled, printable clinical PDF report using ReportLab.

## 3. Standard Consolidated Output Schema

When multiple records are processed, the system outputs the following standardized format:

```markdown
# Patient Longitudinal Medical Summary

## Basic Patient Details
- **Patient ID / Name:** [Patient Identifier]
- **Age / Gender:** [Age] / [Gender]
- **Records Processed:** [Count]

---

## Known Allergies & Sensitivities (If Found)
- **Allergies / Drug Sensitivities:** [Extracted Allergies or None Documented]

---

## Latest Vital Indicators (If Found)
- **Blood Pressure (BP):** [Latest Value] (Recorded Date: [YYYY-MM-DD] / Not Found)
- **Sugar / Glucose Levels:** [Latest Value] (Recorded Date: [YYYY-MM-DD] / Not Found)

---

## Consolidated Diagnoses & Clinical Findings

### 1. [Disease / Diagnosis Name]
- **Date:** [Earliest to Latest Recorded Dates]
- **Disease / Diagnosis:** [Full Diagnosis Name]
- **Symptoms:** [Chief Complaints / Clinical Symptoms]
- **Medications:**
  - [Medicine Name & Strength] — [Decoded Frequency & Duration]
```

## 4. Requirements & Prerequisites

### A. System-Level Prerequisites

- Python 3.10+
- **Tesseract OCR Engine:**
  - Windows: Download and install from UB-Mannheim Tesseract. Default binary location: `C:\Program Files\Tesseract-OCR\tesseract.exe`.
  - Linux (Ubuntu/Debian):
    ```bash
    sudo apt update && sudo apt install -y tesseract-ocr
    ```
  - macOS:
    ```bash
    brew install tesseract
    ```
- **Ollama:**
  - Install Ollama from [ollama.com](https://ollama.com).
  - Verify Ollama is running:
    ```bash
    ollama --version
    ```

### B. Pull Local LLM & Embedding Models

Run the following terminal commands to pull the necessary models:

```bash
# Language model for shorthand expansion and multi-record synthesis
ollama pull qwen2.5:3b

# Embedding model for vector indexing in ChromaDB
ollama pull mxbai-embed-large
```

*(Note: If using `bge-m3`, run `ollama pull bge-m3` instead and update the embedding configuration in `pipeline_service.py`.)*

### C. Python Dependencies (`requirements.txt`)

Create a `requirements.txt` file or install the following packages directly:

```
fastapi
uvicorn
python-multipart
opencv-python
pillow
numpy
pytesseract
langchain-core
langchain-ollama
langchain-chroma
langchain-text-splitters
chromadb
reportlab
httpx
```

Install via pip:

```bash
pip install -r requirements.txt
```

## 5. Project Directory Structure

```
medical_record_summarizer/
│
├── data/
│   └── uploads/                  # Temporary cache for uploaded images
├── chroma_db/                    # Persistent vector storage database
├── pipeline_service.py           # OCR, LLM chains, ChromaDB, and ReportLab PDF logic
├── main.py                       # FastAPI application, routing, and CORS setup
├── requirements.txt              # Project package dependencies
└── README.md                     # Documentation and usage guide
```

## 6. Setup & Execution Guide

### Step 1: Clone or Set Up the Project

```bash
mkdir medical_record_summarizer
cd medical_record_summarizer
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install packages
pip install -r requirements.txt
```

### Step 2: Verify Tesseract OCR Path

In `pipeline_service.py`, confirm that the path to your Tesseract binary is correctly specified:

```python
# Windows example:
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# Linux/macOS (if in standard PATH, this line can be omitted or set to):
# pytesseract.pytesseract.tesseract_cmd = "tesseract"
```

### Step 3: Start the FastAPI Server

Run the API using Uvicorn:

```bash
python main.py
```

Or directly using uvicorn:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API server will start at: `http://127.0.0.1:8000`

- Interactive Swagger UI documentation: `http://127.0.0.1:8000/docs`
- Alternative ReDoc documentation: `http://127.0.0.1:8000/redoc`

## 7. API Endpoints Reference

### 1. Ingest Medical Records

**Endpoint:** `POST /api/records/upload`

**Form Data:**
- `patient_id` (string, required): e.g., `"pat-101"`
- `record_date` (string, optional): e.g., `"2026-09-05"`
- `files` (multipart image files, required): 1 or more JPG/PNG files

**Response:**

```json
{
  "status": "success",
  "patient_id": "pat-101",
  "files_processed": 2,
  "total_chunks_stored": 6
}
```

### 2. List Patient Records

**Endpoint:** `GET /api/records/{patient_id}`

**Response:**

```json
{
  "patient_id": "pat-101",
  "total_records": 2,
  "records": [
    {
      "filename": "prescription_1.jpg",
      "record_date": "2026-08-11"
    },
    {
      "filename": "prescription_2.jpg",
      "record_date": "2026-08-25"
    }
  ]
}
```

### 3. Generate Markdown Summary

**Endpoint:** `GET /api/records/{patient_id}/summary`

**Response:**

```json
{
  "patient_id": "pat-101",
  "summary": "# Patient Longitudinal Medical Summary\n..."
}
```

### 4. Download Summary as PDF

**Endpoint:** `GET /api/records/{patient_id}/summary/pdf`

**Response:** Binary PDF stream (`Content-Type: application/pdf`).

## 8. Verification & Quick Testing

You can run automated integration checks against the running server by passing the `test` argument:

```bash
python main.py test
```

This simulates uploading a synthetic medical prescription, checking stored history, retrieving the synthesized Markdown report, and saving `downloaded_test_summary.pdf` locally.
