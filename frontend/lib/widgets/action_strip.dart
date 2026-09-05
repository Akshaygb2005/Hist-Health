import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActionStrip extends StatelessWidget {
  final String patientId;
  final int recordCount;
  final bool isAnalyzing;
  final bool isPendingAnalysis;
  final VoidCallback onToggleSidebar;
  final VoidCallback onAnalyze;

  const ActionStrip({
    super.key,
    this.patientId = 'pat-101',
    required this.recordCount,
    required this.isAnalyzing,
    required this.isPendingAnalysis,
    required this.onToggleSidebar,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(
        backgroundColor: Colors.white,
        borderColor: AppTheme.brand100,
        borderRadius: 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;
          final leftContent = Row(
            children: [
              InkWell(
                onTap: onToggleSidebar,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.brand50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.brand200),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: AppTheme.brand800,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Patient Records',
                        style: AppTheme.sans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.brand100.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.brand200),
                        ),
                        child: Text(
                          patientId,
                          style: AppTheme.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brand800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$recordCount historical ${recordCount == 1 ? 'report' : 'reports'} currently stored in local index',
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ],
          );

          final rightContent = Column(
            crossAxisAlignment: isNarrow ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isPendingAnalysis
                          ? AppTheme.brand500.withValues(alpha: 0.4)
                          : const Color(0x1F059669),
                      blurRadius: isPendingAnalysis ? 16 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isAnalyzing ? null : onAnalyze,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.brand600, AppTheme.teal600, AppTheme.teal700],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: isPendingAnalysis
                            ? Border.all(color: AppTheme.brand300, width: 2)
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isAnalyzing) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Synthesizing all reports...',
                              style: AppTheme.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                              color: Color(0xFFA7F3D0),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Make this report easy to analyse',
                              style: AppTheme.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isPendingAnalysis) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.amber500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Click to analyze added report before uploading another',
                      style: AppTheme.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.amber800,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                leftContent,
                const SizedBox(height: 16),
                rightContent,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leftContent,
              rightContent,
            ],
          );
        },
      ),
    );
  }
}
