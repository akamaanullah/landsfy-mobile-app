import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class AdminModerationScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const AdminModerationScreen({super.key, required this.userSession});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  List<dynamic> _listings = [];
  List<dynamic> _agencies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadApprovals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovals() async {
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

      final response = await dio.get(ApiConstants.appApprovals);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          final container = res['data'] ?? res;
          setState(() {
            _listings = (container['pending_listings'] ?? container['approvals'] ?? container['listings']) as List<dynamic>? ?? [];
            _agencies = (container['pending_agencies'] ?? container['agencies']) as List<dynamic>? ?? [];
            _isLoading = false;
          });
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to load moderation queue');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      String msg = 'Failed to load moderation queue.';
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

  Future<void> _handleAction(String action, dynamic id, {String? reason}) async {
    try {
      final token = await SecureStorageService.getToken();
      final dio = Dio(BaseOptions(
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'User-ID': widget.userSession['id'],
          'User-Role': widget.userSession['role'],
        },
      ));

      final formData = FormData.fromMap({
        'action': action,
        'id': id.toString(),
      });
      if (reason != null) {
        formData.fields.add(MapEntry('reason', reason));
      }

      final response = await dio.post(
        ApiConstants.appUpdateStatus,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action completed successfully!'), backgroundColor: Colors.green),
          );
          _loadApprovals();
        } else {
          throw Exception(res['message']?.toString() ?? 'Action failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.redAccent),
      );
    }
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=600&q=80';
    }
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}/${path.startsWith('/') ? path.substring(1) : path}';
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
    final purpose = listing['purpose']?.toString() ?? 'buy';
    final category = listing['category_name']?.toString() ?? 'Property';
    final image = _getImageUrl(listing['featured_image']?.toString());
    final agentName = listing['agent_name']?.toString() ?? 'Agent';
    final id = listing['id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 90,
                  height: 70,
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
                      price,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For $purpose • $category',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By: $agentName',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _handleAction('listing_reject', id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: const Size(60, 30),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleAction('listing_approve', id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: const Size(60, 30),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyCard(dynamic agency) {
    final name = agency['name']?.toString() ?? '';
    final logo = _getImageUrl(agency['logo_url']?.toString());
    final owner = agency['owner_name']?.toString() ?? 'Owner';
    final id = agency['id'];

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
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(logo),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  'Owner: $owner',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _handleAction('agency_verify', id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 30),
                ),
                child: const Text('Verify', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () => _handleAction('agency_delete', id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 30),
                ),
                child: const Text('Delete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
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
        title: const Text('Moderation Queue', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Listings'),
            Tab(text: 'Agencies'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _listings.isEmpty
                        ? const Center(child: Text('No pending listings review'))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _listings.length,
                            itemBuilder: (context, idx) => _buildListingCard(_listings[idx]),
                          ),
                    _agencies.isEmpty
                        ? const Center(child: Text('No pending agencies review'))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _agencies.length,
                            itemBuilder: (context, idx) => _buildAgencyCard(_agencies[idx]),
                          ),
                  ],
                ),
    );
  }
}
