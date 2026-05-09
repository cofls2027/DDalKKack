import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl     = 'http://10.0.2.2:4000';
  static const String supabaseUrl = 'https://hczripxpbmtvqwbouexo.supabase.co';
  static const String anonKey     = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjenJpcHhwYm10dnF3Ym91ZXhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1MTcyMzksImV4cCI6MjA5MzA5MzIzOX0.39fhIwIrP-9bwVr_9KEggFwlho0x_OwXz89fnZoF5QY';
  static const String _email      = 'test@test.com';
  static const String _password   = 'test1234';

  String? _token;
  DateTime? _tokenExpiry;
  late Dio _dio;

  ApiService() {
    _dio = Dio();
  }

  // 토큰 만료 여부 확인
  bool get _isTokenExpired {
    if (_token == null || _tokenExpiry == null) return true;
    // 만료 5분 전에 갱신
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  // 토큰 발급
  Future<void> _refreshToken() async {
    final res = await Dio().post(
      '$supabaseUrl/auth/v1/token?grant_type=password',
      options: Options(headers: {
        'apikey': anonKey,
        'Content-Type': 'application/json',
      }),
      data: {'email': _email, 'password': _password},
    );
    _token = res.data['access_token'];
    // expires_in은 초 단위 (보통 3600초 = 1시간)
    final expiresIn = res.data['expires_in'] ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    print('토큰 갱신됨, 만료: $_tokenExpiry');

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer $_token'},
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 300),
    ));
  }

  // 초기화
  Future<void> init() async {
    await _refreshToken();
  }

  // API 호출 전 토큰 체크
  Future<void> _ensureToken() async {
    if (_isTokenExpired) {
      await _refreshToken();
    }
  }

  /// 단건 영수증 업로드
  Future<Map<String, dynamic>> uploadReceipt(File imageFile, String cardType) async {
    await _ensureToken();
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

  /// 배치 영수증 업로드
  Future<Map<String, dynamic>> batchUpload(List<File> imageFiles, String cardType, int headcount,) async {
    await _ensureToken();
    final multipartFiles = await Future.wait(
      imageFiles.map((f) => MultipartFile.fromFile(
      f.path, filename: f.path.split('/').last,
      )),
    );
    final formData = FormData.fromMap({
      'images':       multipartFiles,
      'card_type':    cardType,
      'headcount':    headcount.toString(),
    });
    final response = await _dio.post('/api/receipts/batch', data: formData);
    return response.data;
}

  /// 내 영수증 목록 조회
  Future<List<dynamic>> getReceipts({String? status}) async {
    await _ensureToken();
    final response = await _dio.get(
      '/api/receipts',
      queryParameters: status != null ? {'status': status} : null,
    );
    return response.data['receipts'];
  }
}