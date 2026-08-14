import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/services/auth_api_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onToggleLogin;

  const SignupScreen({
    super.key,
    required this.onSuccess,
    required this.onToggleLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'buyer'; // default
  bool _agreeTerms = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (!_agreeTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms and Conditions';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = AuthApiService();
      await authService.register(
        username: username,
        fullName: fullName,
        email: email,
        password: password,
        role: _selectedRole,
      );

      if (mounted) {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAuthTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: AppColors.black, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.normal),
          prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LANDSFY',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Form Title
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: AppColors.textMain,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up to post ads and unlock premium analytics',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Fields
              _buildAuthTextField(
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline_rounded,
                controller: _fullNameController,
              ),
              const SizedBox(height: 14),
              _buildAuthTextField(
                hintText: 'Username',
                prefixIcon: Icons.alternate_email_rounded,
                controller: _usernameController,
              ),
              const SizedBox(height: 14),
              _buildAuthTextField(
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 14),
              _buildAuthTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),

              // Role choice Dropdown
              const Text(
                'I want to register as:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
                    style: const TextStyle(fontSize: 14, color: AppColors.black, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'buyer', child: Text('Buyer (Search & Saved Properties)')),
                      DropdownMenuItem(value: 'seller', child: Text('Seller (Post Ads & Properties)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedRole = v;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms Agreement
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeTerms,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _agreeTerms = v;
                          });
                        }
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'I agree to LANDSFY\'s Terms of Service & Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider "OR"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : widget.onSuccess,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'G',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Toggle login
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : widget.onToggleLogin,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
