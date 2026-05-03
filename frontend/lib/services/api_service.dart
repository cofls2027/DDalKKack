import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  // 실제 기기 테스트할 때는 PC의 IP로 바꿔야 해요
  // 에뮬레이터: 10.0.2.2 / 실제 기기: 192.168.x.x
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String token   = '여기에_Bearer_토큰';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Authorization': 'Bearer $token'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// 단건 영수증 업로드
  Future<Map<String, dynamic>> uploadReceipt(
    File imageFile,
    String cardType,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'card_type': cardType,
    });

    final response = await _dio.post('/api/receipts/upload', data: formData);
    return response.data;
  }

  /// 배치 영수증 업로드 (갤러리 일괄)
  Future<Map<String, dynamic>> batchUpload(
    List<File> imageFiles,
    String cardType,
  ) async {
    final multipartFiles = await Future.wait(
      imageFiles.map((f) => MultipartFile.fromFile(
        f.path,
        filename: f.path.split('/').last,
      )),
    );

    final formData = FormData.fromMap({
      'images': multipartFiles,
      'card_type': cardType,
    });

    final response = await _dio.post('/api/receipts/batch', data: formData);
    return response.data;
  }

  /// 내 영수증 목록 조회
  Future<List<dynamic>> getReceipts({String? status}) async {
    final response = await _dio.get(
      '/api/receipts',
      queryParameters: status != null ? {'status': status} : null,
    );
    return response.data['receipts'];
  }
}