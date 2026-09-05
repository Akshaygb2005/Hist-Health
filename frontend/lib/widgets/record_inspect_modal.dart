import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/record_model.dart';
import '../theme/app_theme.dart';
import '../api/api_service.dart';

class RecordInspectModal extends StatelessWidget {
  final MedicalRecord record;
  final String patientId;
  final VoidCallback onClose;

  const RecordInspectModal({
    super.key,
    required this.record,
    required this.patientId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrl = ApiService.getFileUrl(patientId, record.filename);
    final isPdf = record.filename.toLowerCase().endsWith('.pdf');
    final isImage = record.filename.toLowerCase().endsWith('.jpg') ||
        record.filename.toLowerCase().endsWith('.jpeg') ||
        record.filename.toLowerCase().endsWith('.png');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x80D1FAE5), Color(0x66CCFBF1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border(bottom: BorderSide(color: AppTheme.slate100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.filename,
                            style: AppTheme.sans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Uploaded Report Document • ${record.recordDate}',
                            style: AppTheme.sans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.brand700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: AppTheme.slate500, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Body: Uploaded File Display
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Uploaded File Visual Preview Area
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0x33D1FAE5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.brand200, width: 2),
                        ),
                        child: Column(
                          children: [
                            if (record.rawBytes != null && isImage) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  Uint8List.fromList(record.rawBytes!),
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ] else if (isImage) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  fileUrl,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildFilePlaceholder(record.filename, 'IMG');
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 180,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brand600),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ] else if (isPdf) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppTheme.rose500,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'PDF',
                                        style: AppTheme.mono(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      record.filename,
                                      style: AppTheme.sans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.slate900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'PDF Document • ${record.size}',
                                      style: AppTheme.sans(
                                        fontSize: 12,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              _buildFilePlaceholder(record.filename, 'DOC'),
                            ],

                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.brand100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.brand600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Verified Encounter Document',
                                    style: AppTheme.sans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.brand800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Document Clinical Details Overview
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.slate50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.slate200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diagnosed Condition',
                                    style: AppTheme.sans(fontSize: 11, color: AppTheme.slate400),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record.diagnosis.isNotEmpty ? record.diagnosis : 'Not specified',
                                    style: AppTheme.sans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.slate900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.slate50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.slate200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vitals Documented',
                                    style: AppTheme.sans(fontSize: 11, color: AppTheme.slate400),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record.bp.isNotEmpty ? record.bp : 'Not specified',
                                    style: AppTheme.sans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.brand700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Medications
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prescribed Regimen in this Slip:',
                              style: AppTheme.sans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.brand800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (record.meds.isEmpty)
                              Text(
                                'No medications documented in this slip.',
                                style: AppTheme.sans(fontSize: 11, color: AppTheme.slate500),
                              )
                            else
                              ...record.meds.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '• $m',
                                      style: AppTheme.sans(fontSize: 11, color: AppTheme.slate700),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppTheme.slate50,
                  border: Border(top: BorderSide(color: AppTheme.slate100)),
                ),
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.slate900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Close',
                    style: AppTheme.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePlaceholder(String filename, String badge) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.brand600, AppTheme.teal600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              badge,
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filename,
            style: AppTheme.sans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate900,
            ),
          ),
          Text(
            'Stored Patient Report Artifact',
            style: AppTheme.sans(fontSize: 11, color: AppTheme.brand700),
          ),
        ],
      ),
    );
  }
}
