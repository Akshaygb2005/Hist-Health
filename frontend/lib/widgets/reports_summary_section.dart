import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/record_model.dart';
import '../theme/app_theme.dart';
import 'pdf_embed_view.dart';

class ReportsSummarySection extends StatelessWidget {
  final String patientId;
  final List<MedicalRecord> records;
  final Uint8List? pdfBytes;
  final String? pdfUrl;
  final bool isGenerating;
  final VoidCallback onOpenPdfModal;
  final VoidCallback onDownloadPdf;

  const ReportsSummarySection({
    super.key,
    this.patientId = 'pat-101',
    required this.records,
    this.pdfBytes,
    this.pdfUrl,
    this.isGenerating = false,
    required this.onOpenPdfModal,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header & Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reports summary',
                  style: AppTheme.sans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Generated official longitudinal PDF document',
                  style: AppTheme.sans(
                    fontSize: 12,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenPdfModal,
                  icon: const Icon(Icons.fullscreen_rounded, size: 16, color: AppTheme.brand700),
                  label: Text(
                    'Full Document Modal',
                    style: AppTheme.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.brand50,
                    side: const BorderSide(color: AppTheme.brand200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: onDownloadPdf,
                  icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'Download PDF',
                    style: AppTheme.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.slate900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Real Generated PDF Document Viewer
        PdfEmbedView(
          patientId: patientId,
          pdfBytes: pdfBytes,
          pdfUrl: pdfUrl,
          isGenerating: isGenerating,
          onDownloadPdf: onDownloadPdf,
        ),
      ],
    );
  }
}
