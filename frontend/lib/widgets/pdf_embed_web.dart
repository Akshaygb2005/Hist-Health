// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildPdfEmbed({
  required String viewId,
  required String pdfUrl,
  required VoidCallback onDownload,
}) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) {
      final iframe = html.IFrameElement()
        ..src = pdfUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    },
  );

  return HtmlElementView(viewType: viewId);
}
