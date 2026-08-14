import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class ManageAgentsScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const ManageAgentsScreen({super.key, required this.userSession});

  @override
  State<ManageAgentsScreen> createState() => _ManageAgentsScreenState();
}

class _ManageAgentsScreenState extends State<ManageAgentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _agents = [];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
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

      final response = await dio.get(ApiConstants.appAgents);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          setState(() {
            _agents = (res['agents'] ?? res['data']?['team'] ?? []) as List<dynamic>;
            _isLoading = false;
          });
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to load agents');
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

  Future<void> _removeAgent(dynamic memberId) async {
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
        'member_id': memberId.toString(),
      });

      final response = await dio.post(
        ApiConstants.appRemoveAgent,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agent removed successfully!'), backgroundColor: Colors.green),
          );
          _loadAgents();
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to remove agent');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildAgentCard(dynamic agent) {
    final name = agent['full_name']?.toString() ?? 'Agent';
    final email = agent['email']?.toString() ?? '';
    final phone = agent['phone']?.toString() ?? '';
    final avatar = _getImageUrl(agent['avatar_url']?.toString());
    final memberId = agent['id'] ?? agent['member_id'];

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
                  email,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove Agent', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('Are you sure you want to remove $name from your agency?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeAgent(memberId);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Remove', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
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
        title: const Text('Manage Agents', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900)),
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
              : _agents.isEmpty
                  ? const Center(child: Text('No agency agents found.'))
                  : RefreshIndicator(
                      onRefresh: _loadAgents,
                      color: AppColors.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: _agents.length,
                        itemBuilder: (context, idx) => _buildAgentCard(_agents[idx]),
                      ),
                    ),
    );
  }
}
