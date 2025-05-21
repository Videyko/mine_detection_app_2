import 'package:mine_detection_app_2/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  Future<String> login(String username, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final token = response['token'];
    _apiService.setAuthToken(token);
    return token;
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout');
    _apiService.clearAuthToken();
  }
}