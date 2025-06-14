import 'package:dio/dio.dart';
import '../models/login_request.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Response> login(LoginRequest loginRequest) async {
    try {
      Response response = await _dio.post(
        'http://joinmeds.in:8082/api/user/login',
        data: loginRequest.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      throw e; // Let the UI catch and handle it
    }
  }
}