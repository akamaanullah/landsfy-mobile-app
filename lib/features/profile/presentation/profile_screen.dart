import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'widgets/role_dashboard_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isShowingLogin = true;
  String _selectedRole = 'Seller';

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _isShowingLogin
          ? LoginScreen(
              onSuccess: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
              onToggleSignup: () {
                setState(() {
                  _isShowingLogin = false;
                });
              },
            )
          : SignupScreen(
              onSuccess: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
              onToggleLogin: () {
                setState(() {
                  _isShowingLogin = true;
                });
              },
            );
    }

    return RoleDashboardView(
      selectedRole: _selectedRole,
      onRoleChanged: (role) {
        setState(() {
          _selectedRole = role;
        });
      },
      onLogout: () {
        setState(() {
          _isLoggedIn = false;
        });
      },
    );
  }
}
