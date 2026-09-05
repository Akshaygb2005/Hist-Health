import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/record_model.dart';
import '../theme/app_theme.dart';
import 'pdf_embed_view.dart';

class PdfViewerModal extends StatelessWidget {
  final String patientId;
  final List<MedicalRecord> records;
  final Uint8List? pdfBytes;
  final String? pdfUrl;
  final VoidCallback onClose;
  final VoidCallback onDownloadPdf;

  const PdfViewerModal({
    super.key,
    this.patientId = 'pat-101',
    required this.records,
    this.pdfBytes,
    this.pdfUrl,
    required this.onClose,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 880, maxHeight: 920),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                color: AppTheme.slate900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Longitudinal Medical Summary Document',
                      style: AppTheme.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: AppTheme.slate300, size: 20),
                      tooltip: 'Close Modal',
                    ),
                  ],
                ),
              ),

              // Embedded PDF Document Viewer
              Expanded(
                child: PdfEmbedView(
                  patientId: patientId,
                  pdfBytes: pdfBytes,
                  pdfUrl: pdfUrl,
                  isGenerating: false,
                  onDownloadPdf: onDownloadPdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
