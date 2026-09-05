import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final int recordCount;
  final VoidCallback onToggleSidebar;
  final VoidCallback onScrollToWhyThis;
  final VoidCallback onScrollToSummary;

  const AppHeader({
    super.key,
    required this.recordCount,
    required this.onToggleSidebar,
    required this.onScrollToWhyThis,
    required this.onScrollToSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: AppTheme.brand100, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Toggle Sidebar + Brand
          Row(
            children: [
              InkWell(
                onTap: onToggleSidebar,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_open_rounded, size: 18, color: AppTheme.brand600),
                      const SizedBox(width: 6),
                      Text(
                        'Records Panel',
                        style: AppTheme.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.brand100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$recordCount',
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
              ),
              const SizedBox(width: 14),
              // Brand Logo & Title
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.brand600, AppTheme.teal800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F059669),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'H+',
                      style: AppTheme.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'HistHealth',
                    style: AppTheme.sans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Nav buttons
          Row(
            children: [
              TextButton(
                onPressed: onScrollToWhyThis,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Why This?',
                  style: AppTheme.sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onScrollToSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brand600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'View Summary',
                  style: AppTheme.sans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
