import 'package:flutter/material.dart';
import '../models/record_model.dart';
import '../theme/app_theme.dart';

class PastRecordsSidebar extends StatelessWidget {
  final bool isOpen;
  final String patientId;
  final List<MedicalRecord> records;
  final VoidCallback onClose;
  final VoidCallback onRefreshRecords;
  final Function(MedicalRecord) onInspectRecord;
  final Function(MedicalRecord) onDeleteRecord;
  final VoidCallback onSummarizeAll;

  const PastRecordsSidebar({
    super.key,
    required this.isOpen,
    this.patientId = 'pat-101',
    required this.records,
    required this.onClose,
    required this.onRefreshRecords,
    required this.onInspectRecord,
    required this.onDeleteRecord,
    required this.onSummarizeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // Backdrop overlay
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: const Color(0x520F172A),
          ),
        ),

        // Slide-out Drawer Panel
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 380,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. Sidebar Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppTheme.slate50,
                    border: Border(bottom: BorderSide(color: AppTheme.slate100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.brand500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Past Records Added',
                            style: AppTheme.sans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.slate200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${records.length}',
                              style: AppTheme.sans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate700,
                              ),
                            ),
                          ),
                        ],
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

                // 2. Active Patient Profile Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0x99ECFDF5),
                    border: Border(bottom: BorderSide(color: AppTheme.brand100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppTheme.brand700,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.folder_shared_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Index',
                                style: AppTheme.sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              Text(
                                patientId,
                                style: AppTheme.mono(
                                  fontSize: 11,
                                  color: AppTheme.brand800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: onRefreshRecords,
                        icon: const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.brand700),
                        label: Text(
                          'Refresh',
                          style: AppTheme.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brand700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppTheme.brand200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Records List
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.folder_off_outlined, size: 36, color: AppTheme.slate300),
                              const SizedBox(height: 8),
                              Text(
                                'No records stored',
                                style: AppTheme.sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slate400,
                                ),
                              ),
                              Text(
                                'Upload a report using the Add Report form.',
                                style: AppTheme.sans(
                                  fontSize: 11,
                                  color: AppTheme.slate400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: records.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final rec = records[index];
                            final isPdf = rec.filename.toLowerCase().endsWith('.pdf');
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xB3F8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.slate200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isPdf ? AppTheme.rose100 : AppTheme.brand100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      isPdf ? 'PDF' : 'DOC',
                                      style: AppTheme.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isPdf ? AppTheme.rose900 : AppTheme.brand800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rec.filename,
                                          style: AppTheme.sans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.slate800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          rec.diagnosis,
                                          style: AppTheme.sans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.brand700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${rec.size} • ${rec.bp}',
                                          style: AppTheme.sans(
                                            fontSize: 10,
                                            color: AppTheme.slate400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // View button (eye icon) -> shows uploaded file!
                                  IconButton(
                                    onPressed: () => onInspectRecord(rec),
                                    icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                                    color: AppTheme.slate600,
                                    hoverColor: AppTheme.brand50,
                                    tooltip: 'View Uploaded File',
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 4),
                                  // Delete button
                                  IconButton(
                                    onPressed: () => onDeleteRecord(rec),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    color: AppTheme.slate400,
                                    hoverColor: AppTheme.rose50,
                                    tooltip: 'Delete Report',
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // 4. Sidebar Footer Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.slate50,
                    border: Border(top: BorderSide(color: AppTheme.slate100)),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onSummarizeAll,
                    icon: const Icon(Icons.bolt, size: 18, color: Colors.white),
                    label: Text(
                      'Summarize All Past Records',
                      style: AppTheme.sans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brand600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
