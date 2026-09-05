import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/download_helper.dart';
import 'pdf_embed_stub.dart'
    if (dart.library.html) 'pdf_embed_web.dart' as embed_helper;

class PdfEmbedView extends StatefulWidget {
  final String patientId;
  final Uint8List? pdfBytes;
  final String? pdfUrl;
  final bool isGenerating;
  final VoidCallback onDownloadPdf;

  const PdfEmbedView({
    super.key,
    required this.patientId,
    required this.pdfBytes,
    required this.pdfUrl,
    required this.isGenerating,
    required this.onDownloadPdf,
  });

  @override
  State<PdfEmbedView> createState() => _PdfEmbedViewState();
}

class _PdfEmbedViewState extends State<PdfEmbedView> {
  String? _activeUrl;
  String _viewId = '';

  @override
  void initState() {
    super.initState();
    _updateUrl();
  }

  @override
  void didUpdateWidget(covariant PdfEmbedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfBytes != widget.pdfBytes || oldWidget.pdfUrl != widget.pdfUrl) {
      _updateUrl();
    }
  }

  void _updateUrl() {
    if (widget.pdfBytes != null && widget.pdfBytes!.isNotEmpty) {
      _activeUrl = createBlobUrlFromBytes(widget.pdfBytes!);
      _viewId = 'pdf-frame-${DateTime.now().millisecondsSinceEpoch}';
    } else if (widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty) {
      _activeUrl = widget.pdfUrl;
      _viewId = 'pdf-frame-${DateTime.now().millisecondsSinceEpoch}';
    } else {
      _activeUrl = null;
      _viewId = '';
    }
  }

  void _openInNewTab() {
    if (_activeUrl != null && _activeUrl!.isNotEmpty) {
      openPdfUrlInNewTab(_activeUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filename = '${widget.patientId}_longitudinal_summary.pdf';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate300, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Professional PDF Toolbar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.slate900,
              border: Border(bottom: BorderSide(color: AppTheme.slate800)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.brand600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'PDF',
                        style: AppTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              filename,
                              style: AppTheme.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.brand900,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.brand700),
                              ),
                              child: Text(
                                'Official PDF',
                                style: AppTheme.mono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.brand300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Official Longitudinal Medical Summary Document',
                          style: AppTheme.sans(
                            fontSize: 10,
                            color: AppTheme.slate400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_activeUrl != null) ...[
                      OutlinedButton.icon(
                        onPressed: _openInNewTab,
                        icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.slate300),
                        label: Text(
                          'Open in New Tab',
                          style: AppTheme.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate200,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppTheme.slate800,
                          side: const BorderSide(color: AppTheme.slate700),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: (_activeUrl != null || widget.pdfBytes != null)
                          ? widget.onDownloadPdf
                          : null,
                      icon: const Icon(Icons.download_rounded, size: 15, color: Colors.white),
                      label: Text(
                        'Download PDF',
                        style: AppTheme.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brand600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.slate700,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Embedded PDF Document View
          Container(
            height: 780,
            color: const Color(0xFFE2E8F0),
            child: widget.isGenerating
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brand600),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Synthesizing and rendering longitudinal PDF...',
                          style: AppTheme.sans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Processing encounters, normalizing prescriptions, and building official document',
                          style: AppTheme.sans(
                            fontSize: 12,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  )
                : (_activeUrl != null && _viewId.isNotEmpty)
                    ? embed_helper.buildPdfEmbed(
                        viewId: _viewId,
                        pdfUrl: _activeUrl!,
                        onDownload: widget.onDownloadPdf,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppTheme.brand50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.brand200),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 36,
                                color: AppTheme.brand600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No PDF Generated Yet',
                              style: AppTheme.sans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upload medical slips above and click "Make this report easy to analyse".\nThe generated longitudinal PDF will be displayed directly here as it is.',
                              textAlign: TextAlign.center,
                              style: AppTheme.sans(
                                fontSize: 12,
                                color: AppTheme.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
