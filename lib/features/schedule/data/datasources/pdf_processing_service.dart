// import 'dart:convert';
import 'dart:io';

// import 'package:http/http.dart' as http;

import '../models/schedule_data.dart';
// import 'schedule_import_service.dart';

class PdfProcessingService {
  static Future<ScheduleData> processSchedulePdf(File pdfFile) async {
    throw UnimplementedError('PDF parsing not yet implemented');
    
    // Original implementation removed - will be restored when PDF parsing is ready:
    // try {
    //   final altBase = const String.fromEnvironment('API_BASE', defaultValue: '');
    //   final bases = <String>[
    //     if (Platform.isAndroid) 'http://10.0.2.2:8000' else 'http://127.0.0.1:8000',
    //     if (!Platform.isAndroid) 'http://localhost:8000',
    //     if (altBase.isNotEmpty) altBase,
    //   ];
    //   Exception? lastError;
    //   for (final base in bases) {
    //     try {
    //       final uri = Uri.parse('$base/parse-pdf');
    //       final request = http.MultipartRequest('POST', uri)
    //         ..files.add(await http.MultipartFile.fromPath('file', pdfFile.path));
    //       request.headers['Accept'] = 'application/json';
    //       final streamed = await request.send().timeout(const Duration(seconds: 20));
    //       final response = await http.Response.fromStream(streamed);
    //       if (response.statusCode == 200) {
    //         final decoded = json.decode(response.body);
    //         String jsonString;
    //         if (decoded is Map<String, dynamic> && decoded['courses'] != null) {
    //           jsonString = json.encode({'courses': decoded['courses']});
    //         } else if (decoded is List) {
    //           jsonString = json.encode({'courses': decoded});
    //         } else {
    //           throw Exception('Unexpected API response format from parser API.');
    //         }
    //         return await ScheduleImportService.importFromJson(jsonString);
    //       } else {
    //         lastError = Exception('Parser API error: HTTP ${response.statusCode}');
    //         continue;
    //       }
    //     } catch (e) {
    //       lastError = e is Exception ? e : Exception(e.toString());
    //       continue;
    //     }
    //   }
    //   throw lastError ?? Exception('Parser API unreachable.');
    // } catch (e) {
    //   throw Exception('Failed to process PDF via API: $e');
    // }
  }
}
