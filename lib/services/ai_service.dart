import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AIService {
  final String endpoint = 'http://<BACKEND-IP>:PORT/analyze';


  Future<String?> sendImageForPrediction(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse(endpoint));
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      return "Error from backend: ${response.statusCode}";
    }
  }
}
