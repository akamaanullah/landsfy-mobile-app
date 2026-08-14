import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class MyListingsScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const MyListingsScreen({super.key, required this.userSession});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
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

      final response = await dio.get(ApiConstants.appListings);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data is String ? jsonDecode(response.data.toString()) : response.data;
        if (res is Map && res['success'] == true) {
          setState(() {
            _listings = (res['data']?['listings'] ?? res['listings'] ?? []) as List<dynamic>;
            _isLoading = false;
          });
        } else {
          throw Exception(res is Map ? (res['message']?.toString() ?? 'Failed to load listings') : 'Invalid response');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      String msg = 'Failed to load listings.';
      if (e.response?.data != null && e.response?.data is Map && e.response?.data['message'] != null) {
        msg = e.response!.data['message'].toString();
      } else if (e.message != null) {
        msg = e.message!;
      }
      setState(() {
        _errorMessage = msg;
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
      return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80';
    }
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}/${path.startsWith('/') ? path.substring(1) : path}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'under_review':
      case 'pending':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPrice(dynamic priceVal, [String purpose = 'sell']) {
    if (priceVal == null) return 'PKR 0';
    final strVal = priceVal.toString().trim();
    if (strVal.startsWith('PKR') || strVal.contains('Crore') || strVal.contains('Lakh') || strVal.contains('Thousand')) {
      return strVal;
    }
    final price = double.tryParse(strVal) ?? 0.0;
    if (price <= 0) return strVal.isEmpty ? 'PKR 0' : strVal;

    if (price >= 10000000) {
      final crore = price / 10000000;
      final formatted = crore.toStringAsFixed(crore % 1 == 0 ? 0 : (crore * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Crore';
    } else if (price >= 100000) {
      final lakh = price / 100000;
      final formatted = lakh.toStringAsFixed(lakh % 1 == 0 ? 0 : (lakh * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Lakh${purpose == 'rent' ? '/mo' : ''}';
    } else if (price >= 1000) {
      final thousand = price / 1000;
      final formatted = thousand.toStringAsFixed(thousand % 1 == 0 ? 0 : (thousand * 10 % 1 == 0 ? 1 : 2));
      return 'PKR $formatted Thousand${purpose == 'rent' ? '/mo' : ''}';
    } else {
      return 'PKR ${price.toStringAsFixed(0)}';
    }
  }

  Widget _buildListingCard(dynamic listing) {
    final title = listing['title']?.toString() ?? '';
    final price = _formatPrice(listing['price'], listing['purpose']?.toString() ?? 'sell');
    final status = listing['status']?.toString() ?? 'under_review';
    final views = listing['views_total']?.toString() ?? '0';
    final image = _getImageUrl(listing['thumbnail']?.toString() ?? listing['featured_image']?.toString());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: image,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${int.tryParse(price)?.toString() ?? price}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(color: _getStatusColor(status), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.visibility_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(views, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('My Listings', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : _listings.isEmpty
                  ? const Center(child: Text('No listings found.'))
                  : RefreshIndicator(
                      onRefresh: _loadListings,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: _listings.length,
                        itemBuilder: (context, idx) => _buildListingCard(_listings[idx]),
                      ),
                    ),
    );
  }
}
