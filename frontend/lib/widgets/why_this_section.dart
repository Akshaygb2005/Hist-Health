import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WhyThisSection extends StatelessWidget {
  const WhyThisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        border: const Border(
          bottom: BorderSide(color: Color(0x33A7F3D0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.brand50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.brand200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                      'Clinical Context & Workflow',
                      style: AppTheme.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Heading
              Text(
                'Why Summarize Longitudinal Health Records?',
                style: AppTheme.sans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate950,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Text(
                  'Patients accumulate reports across multiple consultations, diagnostic labs, and prescription slips. '
                  'Doctor appointments average less than 3 minutes, making it challenging to spot past drug reactions, '
                  'track chronic vitals, or decode abbreviated prescription terms.',
                  style: AppTheme.sans(
                    fontSize: 14,
                    color: AppTheme.slate600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 3 Problem Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildFeatureCard(
                          num: '01',
                          title: 'Prescription Shorthand',
                          desc: 'Latin abbreviations like TDS pc or OD are decoded into plain, actionable dosage schedules.',
                          numGradient: const [Color(0xFFFBBF24), Color(0xFFFDE68A)],
                          numTextColor: const Color(0xFF78350F),
                          borderColor: const Color(0x66A7F3D0),
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureCard(
                          num: '02',
                          title: 'Scattered Vital Metrics',
                          desc: 'Blood pressure and glucose indicators are extracted chronologically to present the latest verified readings.',
                          numGradient: const [Color(0xFF2DD4BF), Color(0xFF99F6E4)],
                          numTextColor: const Color(0xFF115E59),
                          borderColor: const Color(0x6699F6E4),
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureCard(
                          num: '03',
                          title: 'Cross-Encounter Allergies',
                          desc: 'Documented drug reactions from earlier visits remain visible to prevent repeat prescriptions.',
                          numGradient: const [Color(0xFFFB7185), Color(0xFFFECDD3)],
                          numTextColor: const Color(0xFF881337),
                          borderColor: const Color(0x66FECDD3),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          num: '01',
                          title: 'Prescription Shorthand',
                          desc: 'Latin abbreviations like TDS pc or OD are decoded into plain, actionable dosage schedules.',
                          numGradient: const [Color(0xFFFBBF24), Color(0xFFFDE68A)],
                          numTextColor: const Color(0xFF78350F),
                          borderColor: const Color(0x66A7F3D0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          num: '02',
                          title: 'Scattered Vital Metrics',
                          desc: 'Blood pressure and glucose indicators are extracted chronologically to present the latest verified readings.',
                          numGradient: const [Color(0xFF2DD4BF), Color(0xFF99F6E4)],
                          numTextColor: const Color(0xFF115E59),
                          borderColor: const Color(0x6699F6E4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          num: '03',
                          title: 'Cross-Encounter Allergies',
                          desc: 'Documented drug reactions from earlier visits remain visible to prevent repeat prescriptions.',
                          numGradient: const [Color(0xFFFB7185), Color(0xFFFECDD3)],
                          numTextColor: const Color(0xFF881337),
                          borderColor: const Color(0x66FECDD3),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String num,
    required String title,
    required String desc,
    required List<Color> numGradient,
    required Color numTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: numGradient),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: AppTheme.sans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: numTextColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.sans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: AppTheme.sans(
              fontSize: 12,
              color: AppTheme.slate600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
