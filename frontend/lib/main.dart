import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'models/record_model.dart';
import 'theme/app_theme.dart';
import 'widgets/app_header.dart';
import 'widgets/why_this_section.dart';
import 'widgets/action_strip.dart';
import 'widgets/add_report_section.dart';
import 'widgets/reports_summary_section.dart';
import 'widgets/past_records_sidebar.dart';
import 'widgets/record_inspect_modal.dart';
import 'widgets/pdf_viewer_modal.dart';
import 'widgets/toast_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HistHealthApp());
}

class HistHealthApp extends StatelessWidget {
  const HistHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HistHealth — Reports Summary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2FBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.brand600,
          primary: AppTheme.brand600,
        ),
      ),
      home: const HistHealthHomePage(),
    );
  }
}

class HistHealthHomePage extends StatefulWidget {
  const HistHealthHomePage({super.key});

  @override
  State<HistHealthHomePage> createState() => _HistHealthHomePageState();
}

class _HistHealthHomePageState extends State<HistHealthHomePage> {
  final String patientId = 'pat-101';
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _whyThisKey = GlobalKey();
  final GlobalKey _summaryKey = GlobalKey();

  List<MedicalRecord> _records = [];
  bool _isSidebarOpen = false;
  bool _isAnalyzing = false;
  bool _isPendingAnalysis = false;
  bool _isReadyBannerVisible = false;
  String _stagedReportName = '';

  Uint8List? _generatedPdfBytes;
  String? _generatedPdfUrl;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final fetched = await ApiService.fetchPatientRecords(patientId);
    if (!mounted) return;
    setState(() {
      _records = fetched;
    });
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> _handleRefreshRecords() async {
    await _loadRecords();
    if (!mounted) return;
    setState(() {
      _isPendingAnalysis = false;
      _stagedReportName = '';
    });
    ToastNotification.show(context, 'Records refreshed from server.');
  }

  Future<void> _handleAddReport(String filename, String size, Uint8List? bytes) async {
    if (_isPendingAnalysis) {
      ToastNotification.show(context, 'Please click "Make this report easy to analyse" first!');
      return;
    }

    final newRecord = MedicalRecord(
      id: 'rec-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      filename: filename,
      size: size,
      recordDate: DateTime.now().toString().split(' ').first,
      diagnosis: '',
      bp: '',
      sugar: '',
      symptoms: '',
      meds: [],
      fileUrl: ApiService.getFileUrl(patientId, filename),
      rawBytes: bytes,
    );

    setState(() {
      _records.insert(0, newRecord);
      _isPendingAnalysis = true;
      _stagedReportName = filename;
      _isReadyBannerVisible = false;
    });

    if (bytes != null) {
      final updated = await ApiService.uploadRecord(
        patientId: patientId,
        filename: filename,
        fileBytes: bytes,
        recordDate: newRecord.recordDate,
      );
      if (updated != null && updated.isNotEmpty && mounted) {
        setState(() {
          _records = updated;
        });
      }
    }

    if (!mounted) return;
    ToastNotification.show(context, '"$filename" added! Click "Make this report easy to analyse".');
    _scrollController.animateTo(
      180,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleGenerateAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _isGeneratingPdf = true;
    });

    _scrollToSection(_summaryKey);

    // Fetch actual ReportLab generated PDF bytes from backend
    final pdfBytes = await ApiService.fetchSummaryPdfBytes(patientId);

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _isGeneratingPdf = false;
      _isPendingAnalysis = false;
      _stagedReportName = '';
      _isReadyBannerVisible = true;
      if (pdfBytes != null && pdfBytes.isNotEmpty) {
        _generatedPdfBytes = pdfBytes;
        _generatedPdfUrl = ApiService.getPdfUrl(patientId);
      }
    });

    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      ToastNotification.show(context, 'Longitudinal PDF synthesized and displayed below!');
    } else {
      ToastNotification.show(context, 'Could not reach backend API at 127.0.0.1:8000.');
    }
  }

  void _handleInspectRecord(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => RecordInspectModal(
        record: record,
        patientId: patientId,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _handleDeleteRecord(MedicalRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Report', style: AppTheme.sans(fontWeight: FontWeight.bold)),
        content: Text('Delete "${record.filename}" from stored reports?', style: AppTheme.sans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rose600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteRecord(patientId, record.filename);
      if (!mounted) return;
      setState(() {
        _records.removeWhere((r) => r.id == record.id || r.filename == record.filename);
      });
      ToastNotification.show(context, 'Report deleted from records.');
    }
  }

  void _handleOpenPdfModal() {
    showDialog(
      context: context,
      builder: (context) => PdfViewerModal(
        patientId: patientId,
        records: _records,
        pdfBytes: _generatedPdfBytes,
        pdfUrl: _generatedPdfUrl,
        onClose: () => Navigator.of(context).pop(),
        onDownloadPdf: _handleDownloadPdf,
      ),
    );
  }

  Future<void> _handleDownloadPdf() async {
    ToastNotification.show(context, 'Preparing PDF download...');
    final pdfBytes = await ApiService.fetchSummaryPdfBytes(patientId);
    if (!mounted) return;
    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      ApiService.downloadPdf(pdfBytes, '${patientId}_longitudinal_summary.pdf');
      ToastNotification.show(context, 'PDF downloaded successfully!');
    } else {
      ToastNotification.show(context, 'Failed to download PDF from server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Ambient Background Layer with Subtle Gradients and Glows
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8FAF1),
                    Color(0xFFF2FBF7),
                    Color(0xFFEBF4FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brand200.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -140,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.teal200.withValues(alpha: 0.25),
              ),
            ),
          ),

          // 2. Main Page Layout
          Column(
            children: [
              // Sticky App Header
              AppHeader(
                recordCount: _records.length,
                onToggleSidebar: _toggleSidebar,
                onScrollToWhyThis: () => _scrollToSection(_whyThisKey),
                onScrollToSummary: () => _scrollToSection(_summaryKey),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // "Why This?" Landing Section
                      Container(
                        key: _whyThisKey,
                        child: const WhyThisSection(),
                      ),

                      // Main Workspace
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Action Strip
                                ActionStrip(
                                  recordCount: _records.length,
                                  isAnalyzing: _isAnalyzing,
                                  isPendingAnalysis: _isPendingAnalysis,
                                  onToggleSidebar: _toggleSidebar,
                                  onAnalyze: _handleGenerateAnalysis,
                                ),
                                const SizedBox(height: 28),

                                // Add Report Section
                                AddReportSection(
                                  isPendingAnalysis: _isPendingAnalysis,
                                  isReadyBannerVisible: _isReadyBannerVisible,
                                  stagedReportName: _stagedReportName,
                                  onScrollToAnalyze: () {
                                    _scrollController.animateTo(
                                      180,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  onDismissReadyBanner: () {
                                    setState(() {
                                      _isReadyBannerVisible = false;
                                    });
                                  },
                                  onAddReport: _handleAddReport,
                                ),
                                const SizedBox(height: 32),

                                // Reports Summary Section
                                Container(
                                  key: _summaryKey,
                                  child: ReportsSummarySection(
                                    patientId: patientId,
                                    records: _records,
                                    pdfBytes: _generatedPdfBytes,
                                    pdfUrl: _generatedPdfUrl,
                                    isGenerating: _isGeneratingPdf,
                                    onOpenPdfModal: _handleOpenPdfModal,
                                    onDownloadPdf: _handleDownloadPdf,
                                  ),
                                ),
                                const SizedBox(height: 48),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Past Records Expandable Left Sidebar
          PastRecordsSidebar(
            isOpen: _isSidebarOpen,
            patientId: patientId,
            records: _records,
            onClose: _toggleSidebar,
            onRefreshRecords: _handleRefreshRecords,
            onInspectRecord: (rec) {
              _toggleSidebar();
              _handleInspectRecord(rec);
            },
            onDeleteRecord: _handleDeleteRecord,
            onSummarizeAll: () {
              _toggleSidebar();
              _handleGenerateAnalysis();
            },
          ),
        ],
      ),
    );
  }
}
