import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';

class AddReportSection extends StatefulWidget {
  final bool isPendingAnalysis;
  final bool isReadyBannerVisible;
  final String stagedReportName;
  final VoidCallback onScrollToAnalyze;
  final VoidCallback onDismissReadyBanner;
  final Function(String filename, String size, Uint8List? bytes) onAddReport;

  const AddReportSection({
    super.key,
    required this.isPendingAnalysis,
    required this.isReadyBannerVisible,
    required this.stagedReportName,
    required this.onScrollToAnalyze,
    required this.onDismissReadyBanner,
    required this.onAddReport,
  });

  @override
  State<AddReportSection> createState() => _AddReportSectionState();
}

class _AddReportSectionState extends State<AddReportSection> {
  String? _selectedFilename;
  String? _selectedFileSize;
  Uint8List? _selectedBytes;

  Future<void> _pickFile() async {
    if (widget.isPendingAnalysis) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilename = file.name;
          _selectedFileSize = '${(file.size / 1024).round()} KB';
          _selectedBytes = file.bytes;
        });
      }
    } catch (e) {
      // Fallback
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFilename = null;
      _selectedFileSize = null;
      _selectedBytes = null;
    });
  }

  void _submit() {
    if (widget.isPendingAnalysis || _selectedFilename == null) return;
    final filename = _selectedFilename!;
    final size = _selectedFileSize ?? 'Unknown size';

    widget.onAddReport(filename, size, _selectedBytes);
    _clearFile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.cardDecoration(
        backgroundColor: Colors.white,
        borderColor: AppTheme.brand100,
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Locked Banner
          if (widget.isPendingAnalysis) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.amber50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.amber200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.amber100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '!',
                      style: AppTheme.sans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.amber800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANALYSIS REQUIRED BEFORE ADDING MORE REPORTS',
                          style: AppTheme.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.amber950,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: AppTheme.sans(fontSize: 12, color: AppTheme.amber950),
                            children: [
                              const TextSpan(text: 'Report "'),
                              TextSpan(
                                text: widget.stagedReportName.isNotEmpty
                                    ? widget.stagedReportName
                                    : 'New Report',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: '" is added. Click '),
                              const TextSpan(
                                text: '"Make this report easy to analyse"',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: ' above to summarize it before you can add another report.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.onScrollToAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amber200,
                      foregroundColor: AppTheme.amber950,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Text(
                      'Go to Analyze →',
                      style: AppTheme.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.amber950,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 2. Ready Banner
          if (widget.isReadyBannerVisible && !widget.isPendingAnalysis) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.brand50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.brand200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.brand600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Analysed & Synthesized!',
                          style: AppTheme.sans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brand900,
                          ),
                        ),
                        Text(
                          'You can now add another report to the patient history below.',
                          style: AppTheme.sans(
                            fontSize: 11,
                            color: AppTheme.brand700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      widget.onDismissReadyBanner();
                      _pickFile();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.brand300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '+ Add Next Report',
                      style: AppTheme.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 3. Form Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.brand600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Report',
                        style: AppTheme.sans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Upload prescription photo, diagnostic lab slip or medical report document',
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Drop Area Container
          Text(
            'REPORT DOCUMENT / IMAGE',
            style: AppTheme.sans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: widget.isPendingAnalysis ? null : _pickFile,
            borderRadius: BorderRadius.circular(16),
            child: Opacity(
              opacity: widget.isPendingAnalysis ? 0.45 : 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0x33D1FAE5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedFilename != null ? AppTheme.brand500 : AppTheme.brand200,
                    width: 2,
                  ),
                ),
                child: _selectedFilename != null
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.brand200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.brand100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _selectedFilename!.endsWith('.pdf') ? 'PDF' : 'FILE',
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.brand800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFilename!,
                                    style: AppTheme.sans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.slate800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _selectedFileSize ?? '500 KB',
                                    style: AppTheme.sans(
                                      fontSize: 11,
                                      color: AppTheme.slate400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _clearFile,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.rose600,
                              ),
                              child: Text(
                                'Remove',
                                style: AppTheme.sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.rose600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.brand100, AppTheme.teal100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 28,
                              color: AppTheme.brand700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Drop prescription or report image here',
                            style: AppTheme.sans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click to select • Accepts JPG, PNG, Scanned Slips, or PDF',
                            style: AppTheme.sans(
                              fontSize: 12,
                              color: AppTheme.slate500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Submit Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (widget.isPendingAnalysis || _selectedFilename == null) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.slate900,
                disabledBackgroundColor: AppTheme.slate300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18, color: AppTheme.brand500),
                  const SizedBox(width: 8),
                  Text(
                    widget.isPendingAnalysis
                        ? 'Locked — Analyse current report first'
                        : 'Add Report to Patient History',
                    style: AppTheme.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
