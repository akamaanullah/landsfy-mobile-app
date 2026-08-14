import 'package:flutter/material.dart';
import '../data/services/auth_api_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'widgets/role_dashboard_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userSession;
  bool _isLoadingSession = true;
  bool _isShowingLogin = true;
  String _selectedRole = 'Buyer';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = await AuthApiService.getUserSession();
    if (mounted) {
      setState(() {
        _userSession = session;
        if (session != null) {
          _selectedRole = _mapRoleToCapitalized(session['role']?.toString());
        }
        _isLoadingSession = false;
      });
    }
  }

  String _mapRoleToCapitalized(String? rawRole) {
    if (rawRole == null) return 'Buyer';
    final lower = rawRole.toLowerCase();
    if (lower == 'buyer') return 'Buyer';
    if (lower == 'seller') return 'Seller';
    if (lower == 'agent') return 'Agent';
    if (lower == 'agency_owner') return 'Agency Owner';
    if (lower == 'admin') return 'Admin';
    return 'Buyer';
  }

  Future<void> _handleLogout() async {
    await AuthApiService.clearUserSession();
    if (mounted) {
      setState(() {
        _userSession = null;
        _isShowingLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userSession == null) {
      return _isShowingLogin
          ? LoginScreen(
              onSuccess: _checkSession,
              onToggleSignup: () {
                setState(() {
                  _isShowingLogin = false;
                });
              },
            )
          : SignupScreen(
              onSuccess: _checkSession,
              onToggleLogin: () {
                setState(() {
                  _isShowingLogin = true;
                });
              },
            );
    }

    return RoleDashboardView(
      userSession: _userSession!,
      selectedRole: _selectedRole,
      onRoleChanged: (role) {
        setState(() {
          _selectedRole = role;
        });
      },
      onLogout: _handleLogout,
      onSessionUpdated: _checkSession,
    );
  }
}
