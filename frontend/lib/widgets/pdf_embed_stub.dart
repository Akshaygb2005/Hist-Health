import 'package:flutter/material.dart';

Widget buildPdfEmbed({
  required String viewId,
  required String pdfUrl,
  required VoidCallback onDownload,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
        const SizedBox(height: 12),
        const Text(
          'PDF Document Ready',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onDownload,
          icon: const Icon(Icons.download),
          label: const Text('Download PDF Document'),
        ),
      ],
    ),
  );
}
