import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/record_model.dart';
import '../utils/download_helper.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static String getFileUrl(String patientId, String filename) {
    return '$baseUrl/api/records/$patientId/file/$filename';
  }

  static Future<List<MedicalRecord>> fetchPatientRecords(String patientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/records/$patientId'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recordsJson = data['records'] ?? [];
        return recordsJson.map((r) => MedicalRecord.fromJson(r)).toList();
      }
    } catch (e) {
      // Fallback if backend is warming up
    }
    return [];
  }

  static Future<List<MedicalRecord>?> uploadRecord({
    required String patientId,
    required String filename,
    required Uint8List fileBytes,
    required String recordDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/records/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['patient_id'] = patientId;
      request.fields['record_date'] = recordDate;
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          fileBytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recordsJson = data['records'] ?? [];
        return recordsJson.map((r) => MedicalRecord.fromJson(r)).toList();
      }
    } catch (e) {
      // Return null on failure
    }
    return null;
  }

  static Future<String> fetchSummaryMarkdown(String patientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/records/$patientId/summary'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'] ?? '';
      }
    } catch (e) {
      // Return fallback
    }
    return '';
  }

  static String getPdfUrl(String patientId) {
    return '$baseUrl/api/records/$patientId/summary/pdf?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<Uint8List?> fetchSummaryPdfBytes(String patientId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/records/$patientId/summary/pdf'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  static Future<bool> deleteRecord(String patientId, String filename) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/api/records/$patientId/file/$filename'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<MedicalRecord>?> resetPatientData(String patientId) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/api/records/$patientId/reset'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recordsJson = data['records'] ?? [];
        return recordsJson.map((r) => MedicalRecord.fromJson(r)).toList();
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  static void downloadPdf(Uint8List bytes, String filename) {
    downloadFileFromBytes(bytes, filename);
  }
}
