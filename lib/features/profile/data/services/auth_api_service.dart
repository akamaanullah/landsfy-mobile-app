import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  String _extractErrorMessage(DioException e, String fallbackMsg) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data is String && data.isNotEmpty) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map && parsed.containsKey('message')) {
            return parsed['message'].toString();
          }
        } catch (_) {}
      }
    }
    return e.message ?? fallbackMsg;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.appLogin,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? jsonDecode(response.data.toString()) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['user'] != null) {
          final userMap = json['user'] as Map<String, dynamic>;
          if (json['token'] != null) {
            await SecureStorageService.saveToken(json['token'].toString());
          }
          await _saveUserSession(userMap);
          return json;
        } else {
          throw Exception(json['message']?.toString() ?? 'Invalid credentials');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Authentication failed'));
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? agencyName,
    String? agencyPhone,
    String? agencyAddress,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.appRegister,
        data: {
          'username': username,
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
          'agency_name': agencyName,
          'agency_phone': agencyPhone,
          'agency_address': agencyAddress,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? jsonDecode(response.data.toString()) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['user'] != null) {
          final userMap = json['user'] as Map<String, dynamic>;
          if (json['token'] != null) {
            await SecureStorageService.saveToken(json['token'].toString());
          }
          await _saveUserSession(userMap);
          return json;
        } else {
          throw Exception(json['message']?.toString() ?? 'Registration failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Registration failed'));
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> user) async {
    await SecureStorageService.saveUserSession(jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final data = await SecureStorageService.getUserSession();
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> clearUserSession() async {
    await SecureStorageService.clearAll();
  }
}
