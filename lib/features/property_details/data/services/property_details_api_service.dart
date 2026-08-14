import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class PropertyDetailsApiService {
  final Dio _dio;

  PropertyDetailsApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  Future<Map<String, dynamic>> getPropertyDetails(String slug) async {
    try {
      final response = await _dio.get(
        ApiConstants.propertyDetail,
        queryParameters: {'slug': slug},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? throw Exception('API returned HTML instead of JSON')
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          return json;
        } else {
          throw Exception(json['message']?.toString() ?? 'Failed to load property details');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'An unknown error occurred');
    }
  }
}
