import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class AgenciesManagementScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const AgenciesManagementScreen({super.key, required this.userSession});

  @override
  State<AgenciesManagementScreen> createState() => _AgenciesManagementScreenState();
}

class _AgenciesManagementScreenState extends State<AgenciesManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _agencies = [];

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  Future<void> _loadAgencies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await SecureStorageService.getToken();
      final dio = Dio(BaseOptions(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'User-ID': widget.userSession['id'],
          'User-Role': widget.userSession['role'],
        },
      ));

      final response = await dio.get(ApiConstants.appAgencies);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data is String ? jsonDecode(response.data.toString()) : response.data;
        if (res is Map && res['success'] == true) {
          setState(() {
            _agencies = (res['agencies'] ?? res['data']?['agencies'] ?? []) as List<dynamic>;
            _isLoading = false;
          });
        } else {
          throw Exception(res is Map ? (res['message']?.toString() ?? 'Failed to load agencies') : 'Invalid response');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to load agencies';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=400&q=80';
    }
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}/${path.startsWith('/') ? path.substring(1) : path}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Agencies Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAgencies,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : _agencies.isEmpty
                  ? const Center(
                      child: Text(
                        'No registered agencies found.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _agencies.length,
                      itemBuilder: (context, index) {
                        final agency = _agencies[index];
                        final name = agency['name']?.toString() ?? 'Agency Name';
                        final email = agency['email']?.toString() ?? 'No Email';
                        final phone = agency['phone']?.toString() ?? 'No Phone';
                        final logo = _getImageUrl(agency['logo']?.toString());
                        final isVerified = agency['is_verified'] == 1 || agency['is_verified'] == '1' || agency['is_verified'] == true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: logo,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(Icons.corporate_fare_rounded, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.textMain,
                                              ),
                                            ),
                                          ),
                                          if (isVerified)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.verified_rounded, color: Colors.blue, size: 14),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'VERIFIED',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        phone,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
