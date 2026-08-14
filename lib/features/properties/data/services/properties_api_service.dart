import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../home/data/models/property_model.dart';

class PropertiesApiService {
  final Dio _dio;

  PropertiesApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  /// Fetches paginated properties from the live API with dynamic filters
  Future<Map<String, dynamic>> getProperties({
    String? query,
    String? city,
    String? location,
    String? purpose,
    int? categoryId,
    int? subtypeId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    Map<String, dynamic>? extraParams,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
      };

      if (extraParams != null) {
        queryParams.addAll(extraParams);
      }

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (location != null && location.isNotEmpty) queryParams['location'] = location;
      if (purpose != null && purpose.isNotEmpty && purpose != 'All') {
        queryParams['purpose'] = purpose.toLowerCase();
      }
      if (categoryId != null && categoryId > 0) queryParams['cat_id'] = categoryId;
      if (subtypeId != null && subtypeId > 0) queryParams['type_id'] = subtypeId;
      if (minPrice != null && minPrice > 0) queryParams['min_price'] = minPrice;
      if (maxPrice != null && maxPrice > 0) queryParams['max_price'] = maxPrice;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await _dio.get(
        ApiConstants.propertiesData,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? throw Exception('API returned HTML instead of JSON')
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          final List<dynamic> rawList = json['data'] as List<dynamic>;
          final properties = rawList
              .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
              .toList();

          final rawMeta = json['meta'] as Map<String, dynamic>? ?? {};
          final int total = int.tryParse(rawMeta['total']?.toString() ?? '0') ?? 0;
          final int currentPage = int.tryParse(rawMeta['page']?.toString() ?? '1') ?? 1;

          return {
            'properties': properties,
            'total': total,
            'page': currentPage,
          };
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
