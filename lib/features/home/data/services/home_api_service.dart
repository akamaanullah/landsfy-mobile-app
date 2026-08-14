import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/home_data_model.dart';

class HomeApiService {
  final Dio _dio;

  HomeApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  /// Fetches all home screen data from the live API
  Future<HomeData> getHomeData() async {
    try {
      final response = await _dio.get(ApiConstants.homeData);

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? throw Exception('API returned HTML instead of JSON')
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          return HomeData.fromJson(json['data'] as Map<String, dynamic>);
        } else {
          throw Exception(json['message']?.toString() ?? 'API returned failure');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      default:
        return e.message ?? 'An unknown error occurred';
    }
  }
}
