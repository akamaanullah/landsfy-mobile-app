import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class LeadsScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const LeadsScreen({super.key, required this.userSession});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _leads = [];

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
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

      final response = await dio.get(ApiConstants.appLeads);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          setState(() {
            _leads = (res['data']?['inquiries'] ?? res['recent_leads'] ?? res['leads'] ?? []) as List<dynamic>;
            _isLoading = false;
          });
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to load leads');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80';
    }
    if (path.startsWith('http')) return path;
    return '${ApiConstants.baseUrl}/${path.startsWith('/') ? path.substring(1) : path}';
  }

  void _launchWhatsApp(String phone, String propertyTitle) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+|-|\+'), '');
    final msg = Uri.encodeComponent('Hi, I am interested in your listing: $propertyTitle');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void _launchCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    try {
      await launchUrl(url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Phone dialer')),
      );
    }
  }

  Widget _buildLeadCard(dynamic lead) {
    final name = lead['buyer_name']?.toString() ?? lead['full_name']?.toString() ?? 'Interested Buyer';
    final avatar = _getImageUrl(lead['buyer_avatar']?.toString() ?? lead['avatar_url']?.toString());
    final propTitle = lead['property_title']?.toString() ?? lead['title']?.toString() ?? 'Property Listing';
    final type = lead['interaction_type']?.toString() ?? 'inquiry';
    final phone = lead['phone']?.toString() ?? '+923000000000';

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
            backgroundImage: CachedNetworkImageProvider(avatar),
            radius: 22,
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
                  'Interested in: $propTitle',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      type == 'whatsapp_click' ? Icons.chat_outlined : Icons.phone_callback_rounded,
                      size: 11,
                      color: type == 'whatsapp_click' ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type == 'whatsapp_click' ? 'WhatsApp Lead' : 'Call Inquiry',
                      style: TextStyle(
                        fontSize: 10,
                        color: type == 'whatsapp_click' ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.call_rounded, color: Colors.blue, size: 20),
                onPressed: () => _launchCall(phone),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.green, size: 20),
                onPressed: () => _launchWhatsApp(phone, propTitle),
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
        title: const Text('Buyer Leads', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
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
              : _leads.isEmpty
                  ? const Center(child: Text('No buyer leads recorded.'))
                  : RefreshIndicator(
                      onRefresh: _loadLeads,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: _leads.length,
                        itemBuilder: (context, idx) => _buildLeadCard(_leads[idx]),
                      ),
                    ),
    );
  }
}
