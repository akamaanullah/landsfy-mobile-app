import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userSession;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.userSession,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userSession['full_name']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.userSession['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.userSession['phone']?.toString() ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        ApiConstants.appUpdateProfile,
        data: {
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text.isNotEmpty ? _passwordController.text : null,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        final res = response.data;
        if (res['success'] == true && res['user'] != null) {
          // Save new session in preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_session', jsonEncode(res['user']));
          
          if (!mounted) return;
          widget.onProfileUpdated();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          throw Exception(res['message']?.toString() ?? 'Failed to update profile');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.person_rounded,
                label: 'Full Name',
                child: TextFormField(
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Full Name is required' : null,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter your full name'),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.email_rounded,
                label: 'Email Address',
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Email is required' : null,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter your email'),
                ),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.phone_rounded,
                label: 'Phone Number',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter phone number'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
              const SizedBox(height: 4),
              const Text(
                'Leave blank if you do not want to change password',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              _buildFieldCard(
                icon: Icons.lock_rounded,
                label: 'New Password',
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '••••••••'),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard({required IconData icon, required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
