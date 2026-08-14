import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class UserManagementScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  const UserManagementScreen({super.key, required this.userSession});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];

  String _searchQuery = '';
  String _selectedRoleFilter = 'All';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
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

      final response = await dio.get(ApiConstants.appUsers);

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data is String ? jsonDecode(response.data.toString()) : response.data;
        if (res is Map && res['success'] == true) {
          setState(() {
            _allUsers = (res['users'] ?? []) as List<dynamic>;
            _applyFilters();
            _isLoading = false;
          });
        } else {
          throw Exception(res is Map ? (res['message']?.toString() ?? 'Failed to load users') : 'Invalid response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to load users';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final name = (u['full_name'] ?? '').toString().toLowerCase();
        final username = (u['username'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        final q = _searchQuery.toLowerCase();

        final matchesSearch = q.isEmpty || name.contains(q) || username.contains(q) || email.contains(q);

        final role = (u['role'] ?? 'buyer').toString().toLowerCase();
        final matchesRole = _selectedRoleFilter == 'All' ||
            (_selectedRoleFilter == 'Buyer' && role == 'buyer') ||
            (_selectedRoleFilter == 'Seller' && role == 'seller') ||
            (_selectedRoleFilter == 'Agent' && role == 'agent') ||
            (_selectedRoleFilter == 'Agency Owner' && (role == 'agency_owner' || role == 'agency owner')) ||
            (_selectedRoleFilter == 'Admin' && role == 'admin');

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _toggleUserStatus(dynamic u) async {
    final currentStatus = (u['status'] ?? 'active').toString().toLowerCase();
    final newStatus = currentStatus == 'blocked' || currentStatus == 'suspended' ? 'active' : 'suspended';
    final userId = u['id'];

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

      final response = await dio.post(
        ApiConstants.appUpdateUserStatus,
        data: {
          'target_user_id': userId,
          'status': newStatus,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data?['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User status updated to $newStatus!'),
            backgroundColor: newStatus == 'suspended' ? Colors.red : Colors.green,
          ),
        );
        _loadUsers();
      } else {
        throw Exception(response.data?['message']?.toString() ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message']?.toString() ?? e.message ?? 'Failed to update user status';
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'agency_owner':
      case 'agency owner':
        return Colors.blue;
      case 'agent':
        return AppColors.primary;
      case 'seller':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = ['All', 'Buyer', 'Seller', 'Agent', 'Agency Owner', 'Admin'];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilters();
                  },
                  style: const TextStyle(fontSize: 14, color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or username...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: roles.map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRoleFilter = role;
                            _applyFilters();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(Icons.check_rounded, size: 14, color: AppColors.black),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                role,
                                style: TextStyle(
                                  color: isSelected ? AppColors.black : Colors.white,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Main Body Content
          Expanded(
            child: _isLoading
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
                                onPressed: _loadUsers,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found matching filters.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final u = _filteredUsers[index];
                              final fullName = u['full_name']?.toString() ?? u['username']?.toString() ?? 'User';
                              final email = u['email']?.toString() ?? 'No Email';
                              final role = u['role']?.toString() ?? 'buyer';
                              final status = (u['status'] ?? 'active').toString().toLowerCase();
                              final isSuspended = status == 'suspended' || status == 'blocked' || status == 'inactive';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: _getRoleColor(role).withValues(alpha: 0.15),
                                      child: Text(
                                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          color: _getRoleColor(role),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: AppColors.textMain,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            email,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: _getRoleColor(role).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  role.toUpperCase().replaceAll('_', ' '),
                                                  style: TextStyle(
                                                    color: _getRoleColor(role),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isSuspended ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  status.toUpperCase(),
                                                  style: TextStyle(
                                                    color: isSuspended ? Colors.red : Colors.green,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isSuspended ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                                        color: isSuspended ? Colors.green : Colors.red,
                                      ),
                                      tooltip: isSuspended ? 'Activate User' : 'Suspend User',
                                      onPressed: () => _toggleUserStatus(u),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
