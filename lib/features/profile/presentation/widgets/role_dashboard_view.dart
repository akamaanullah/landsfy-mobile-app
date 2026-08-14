import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/favorites_manager.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../screens/admin_moderation_screen.dart';
import '../screens/user_management_screen.dart';
import '../screens/agencies_management_screen.dart';
import '../screens/my_listings_screen.dart';
import '../screens/leads_screen.dart';
import '../screens/manage_agents_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/add_property_screen.dart';
import 'stat_card.dart';
import 'profile_menu_tile.dart';

class RoleDashboardView extends StatefulWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onLogout;
  final VoidCallback onSessionUpdated;
  final Map<String, dynamic> userSession;

  const RoleDashboardView({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onLogout,
    required this.onSessionUpdated,
    required this.userSession,
  });

  @override
  State<RoleDashboardView> createState() => _RoleDashboardViewState();
}

class _RoleDashboardViewState extends State<RoleDashboardView> {
  int _savedListingsCount = 0;
  Map<String, String> _dynamicStats = {};
  // ignore: unused_field
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadSavedListingsCount();
    _fetchRoleStats();
  }

  @override
  void didUpdateWidget(covariant RoleDashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRole != oldWidget.selectedRole) {
      _loadSavedListingsCount();
      _fetchRoleStats();
    }
  }

  Future<void> _loadSavedListingsCount() async {
    final list = await FavoritesManager.getFavorites();
    if (mounted) {
      setState(() {
        _savedListingsCount = list.length;
      });
    }
  }

  Future<void> _fetchRoleStats() async {
    final userId = widget.userSession['id']?.toString();
    final role = widget.userSession['role']?.toString();
    if (userId == null || role == null) return;

    if (mounted) {
      setState(() {
        _isLoadingStats = true;
      });
    }

    try {
      final token = await SecureStorageService.getToken();
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'User-ID': userId,
          'User-Role': role,
        },
      ));

      final roleLower = widget.selectedRole.toLowerCase().replaceAll(' ', '_');
      final response = await dio.get(ApiConstants.appStats);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true) {
          final stats = data['stats'] as Map<String, dynamic>?;
          if (mounted) {
            setState(() {
              if (roleLower == 'admin') {
                _dynamicStats = {
                  'total_users': stats?['total_users']?.toString() ?? '0',
                  'pending_reviews': stats?['pending_props']?.toString() ?? '0',
                  'active_properties': stats?['active_props']?.toString() ?? '0',
                  'reports_flagged': stats?['reports_flagged']?.toString() ?? '0',
                };
              } else if (roleLower == 'agency_owner') {
                _dynamicStats = {
                  'active_agents': stats?['active_agents']?.toString() ?? '0',
                  'agency_listings': stats?['agency_listings']?.toString() ?? '0',
                  'total_leads': stats?['total_leads']?.toString() ?? '0',
                  'total_revenue': stats?['total_revenue']?.toString() ?? '0',
                };
              } else if (roleLower == 'agent') {
                final clicks = int.tryParse(stats?['whatsapp_clicks']?.toString() ?? '0') ?? 0;
                final calls = int.tryParse(stats?['call_inquiries']?.toString() ?? '0') ?? 0;
                _dynamicStats = {
                  'active_clients': stats?['active_clients']?.toString() ?? '0',
                  'total_listings': stats?['total_listings']?.toString() ?? '0',
                  'total_inquiries': (clicks + calls).toString(),
                  'est_commission': stats?['est_commission']?.toString() ?? '0',
                };
              } else if (roleLower == 'seller') {
                _dynamicStats = {
                  'total_properties': stats?['total_properties']?.toString() ?? '0',
                  'total_views': stats?['total_views']?.toString() ?? '0',
                  'total_leads': stats?['total_leads']?.toString() ?? '0',
                  'total_sold': stats?['total_sold']?.toString() ?? '0',
                };
              } else if (roleLower == 'buyer') {
                _dynamicStats = {
                  'saved_listings': stats?['saved_listings']?.toString() ?? '$_savedListingsCount',
                  'total_inquiries': stats?['total_inquiries']?.toString() ?? '0',
                  'agents_messaged': stats?['agents_messaged']?.toString() ?? '0',
                  'viewed_history': stats?['viewed_history']?.toString() ?? '0',
                };
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading dynamic role stats: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = widget.selectedRole;
    final onLogout = widget.onLogout;
    final userSession = widget.userSession;

    final Map<String, String> roleSubtitles = {
      'Buyer': 'Premium Home Buyer',
      'Seller': 'Individual Property Seller',
      'Agent': 'Certified LANDSFY Agent',
      'Agency Owner': 'Agency Principal Owner',
      'Admin': 'System Administrator',
    };

    final Map<String, List<Map<String, dynamic>>> roleStats = {
      'Buyer': [
        {
          'value': _dynamicStats['saved_listings'] ?? '$_savedListingsCount',
          'label': 'Saved Listings',
          'icon': Icons.favorite_rounded,
          'color': Colors.red,
        },
        {
          'value': _dynamicStats['total_inquiries'] ?? '0',
          'label': 'My Inquiries',
          'icon': Icons.chat_bubble_rounded,
          'color': Colors.green,
        },
        {
          'value': _dynamicStats['agents_messaged'] ?? '0',
          'label': 'Contacted Agents',
          'icon': Icons.contact_mail_rounded,
          'color': Colors.teal,
        },
        {
          'value': _dynamicStats['viewed_history'] ?? '0',
          'label': 'Viewed History',
          'icon': Icons.history_rounded,
          'color': Colors.blueGrey,
        },
      ],
      'Seller': [
        {'value': _dynamicStats['total_properties'] ?? '0', 'label': 'Listed Properties', 'icon': Icons.home_rounded, 'color': AppColors.primary},
        {'value': _dynamicStats['total_views'] ?? '0', 'label': 'Total Views', 'icon': Icons.visibility_rounded, 'color': Colors.blue},
        {'value': _dynamicStats['total_leads'] ?? '0', 'label': 'Buyer Inquiries', 'icon': Icons.chat_bubble_rounded, 'color': Colors.green},
        {'value': _dynamicStats['total_sold'] ?? '0', 'label': 'Closed Deals', 'icon': Icons.handshake_rounded, 'color': Colors.orange},
      ],
      'Agent': [
        {'value': _dynamicStats['active_clients'] ?? '0', 'label': 'Active Clients', 'icon': Icons.people_alt_rounded, 'color': Colors.indigo},
        {'value': _dynamicStats['total_listings'] ?? '0', 'label': 'My Listings', 'icon': Icons.business_center_rounded, 'color': AppColors.primary},
        {'value': _dynamicStats['total_inquiries'] ?? '0', 'label': 'Leads & Inquiries', 'icon': Icons.question_answer_rounded, 'color': Colors.green},
        {'value': _dynamicStats['est_commission'] ?? '0', 'label': 'Est. Commission', 'icon': Icons.payments_rounded, 'color': Colors.amber},
      ],
      'Agency Owner': [
        {'value': _dynamicStats['active_agents'] ?? '0', 'label': 'Active Agents', 'icon': Icons.supervised_user_circle_rounded, 'color': Colors.blue},
        {'value': _dynamicStats['agency_listings'] ?? '0', 'label': 'Agency Listings', 'icon': Icons.home_work_rounded, 'color': AppColors.primary},
        {'value': _dynamicStats['total_leads'] ?? '0', 'label': 'Total Leads', 'icon': Icons.campaign_rounded, 'color': Colors.teal},
        {'value': _dynamicStats['total_revenue'] ?? '0', 'label': 'Total Revenue', 'icon': Icons.monetization_on_rounded, 'color': Colors.green},
      ],
      'Admin': [
        {'value': _dynamicStats['total_users'] ?? '0', 'label': 'Total Users', 'icon': Icons.people_rounded, 'color': Colors.purple},
        {'value': _dynamicStats['pending_reviews'] ?? '0', 'label': 'Pending Approvals', 'icon': Icons.pending_actions_rounded, 'color': Colors.amber},
        {'value': _dynamicStats['active_properties'] ?? '0', 'label': 'Active Listings', 'icon': Icons.check_circle_rounded, 'color': Colors.green},
        {'value': _dynamicStats['reports_flagged'] ?? '0', 'label': 'Reports Flagged', 'icon': Icons.report_problem_rounded, 'color': Colors.red},
      ],
    };

    final Map<String, List<Map<String, dynamic>>> roleActions = {
      'Buyer': [
        {'title': 'Saved Searches', 'subtitle': 'Manage your saved search filters', 'icon': Icons.saved_search_rounded},
        {'title': 'My Shortlists', 'subtitle': 'Properties you favorited recently', 'icon': Icons.favorite_outline_rounded},
        {'title': 'Viewed History', 'subtitle': 'Properties you have visited', 'icon': Icons.history_rounded},
        {'title': 'Contacted Agents', 'subtitle': 'History of agent conversations', 'icon': Icons.chat_bubble_outline_rounded},
      ],
      'Seller': [
        {'title': 'My Properties', 'subtitle': 'Manage your active listed ads', 'icon': Icons.list_alt_rounded},
        {'title': 'Post New Property', 'subtitle': 'List a new property for sale/rent', 'icon': Icons.add_circle_outline_rounded},
        {'title': 'Buyer Leads', 'subtitle': 'View interested buyer contacts', 'icon': Icons.people_rounded},
        {'title': 'Buyer Inquiries', 'subtitle': 'Direct messages from buyers', 'icon': Icons.forum_rounded},
        {'title': 'Seller Analytics', 'subtitle': 'Views, clicks and ad performance', 'icon': Icons.analytics_rounded},
      ],
      'Agent': [
        {'title': 'My Listed Properties', 'subtitle': 'Manage properties listed under you', 'icon': Icons.domain_rounded},
        {'title': 'Client Leads', 'subtitle': 'Manage assigned leads and inquiries', 'icon': Icons.connect_without_contact_rounded},
        {'title': 'Commission Tracker', 'subtitle': 'Track deals and commissions earned', 'icon': Icons.account_balance_wallet_rounded},
        {'title': 'Agency Profile', 'subtitle': 'Details of your affiliated agency', 'icon': Icons.corporate_fare_rounded},
        {'title': 'Agent Subscription', 'subtitle': 'Manage agent package and limits', 'icon': Icons.card_membership_rounded},
      ],
      'Agency Owner': [
        {'title': 'Manage Agents', 'subtitle': 'Add, remove or monitor agency agents', 'icon': Icons.people_outline_rounded},
        {'title': 'Agency Listings', 'subtitle': 'Manage all properties listed by your agency', 'icon': Icons.apartment_rounded},
        {'title': 'Analytics Dashboard', 'subtitle': 'Review agency metrics and sales reports', 'icon': Icons.insights_rounded},
        {'title': 'Subscription Plan', 'subtitle': 'Manage agency features and billing plan', 'icon': Icons.stars_rounded},
        {'title': 'Company Settings', 'subtitle': 'Configure agency contact and details', 'icon': Icons.settings_applications_rounded},
      ],
      'Admin': [
        {'title': 'All Property', 'subtitle': 'View and manage all platform properties', 'icon': Icons.list_alt_rounded},
        {'title': 'Approvals', 'subtitle': 'Review pending property & agency submissions', 'icon': Icons.check_circle_outline_rounded},
        {'title': 'Users', 'subtitle': 'Manage user accounts, roles and status', 'icon': Icons.people_outline_rounded},
        {'title': 'Agencies', 'subtitle': 'Review agencies and verification status', 'icon': Icons.business_rounded},
        {'title': 'Settings', 'subtitle': 'Configure account preferences and profile', 'icon': Icons.settings_rounded},
      ],
    };

    final currentStats = roleStats[selectedRole] ?? [];
    final currentActions = roleActions[selectedRole] ?? [];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [


            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: () {
                        String avatar = userSession['avatar_url']?.toString() ?? '';
                        if (avatar.isNotEmpty && !avatar.startsWith('http://') && !avatar.startsWith('https://')) {
                          avatar = 'https://landsfy.com/${avatar.startsWith('/') ? avatar.substring(1) : avatar}';
                        }
                        return avatar.isNotEmpty
                            ? Image.network(
                                avatar,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.white,
                                  child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: AppColors.white,
                                child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                              );
                      }(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userSession['full_name']?.toString() ?? 'User Name',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userSession['email']?.toString() ?? 'user@landsfy.com',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      roleSubtitles[selectedRole]?.toUpperCase() ?? '',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Grid (2x2)
            if (currentStats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(stat: currentStats[0])),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(stat: currentStats[1])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: StatCard(stat: currentStats[2])),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(stat: currentStats[3])),
                      ],
                    ),
                  ],
                ),
              ),

            // Profile Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedRole Panel',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...currentActions.map((act) {
                    final title = act['title'].toString();
                    return ProfileMenuTile(
                      icon: act['icon'] as IconData,
                      title: title,
                      subtitle: act['subtitle'].toString(),
                      onTap: () {
                        if (title == 'My Shortlists' || title == 'My Favorites') {
                          context.goNamed('home', queryParameters: {'tab': '2'});
                        } else if (title == 'Post New Property') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddPropertyScreen(userSession: userSession),
                            ),
                          ).then((success) {
                            if (success == true) {
                              _fetchRoleStats();
                            }
                          });
                        } else if (title == 'Saved Searches') {
                          context.goNamed('home', queryParameters: {'tab': '1'});
                        } else if (title == 'Approvals' || title == 'Moderation Queue') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminModerationScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'Users' || title == 'User Management') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserManagementScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'Agencies') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AgenciesManagementScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'All Property' || title == 'My Properties' || title == 'My Listings' || title == 'Agency Listings' || title == 'My Listed Properties') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyListingsScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'Buyer Leads' || title == 'Client Leads' || title == 'Total Leads') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeadsScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'Manage Agents') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManageAgentsScreen(userSession: userSession),
                            ),
                          );
                        } else if (title == 'Settings') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                userSession: userSession,
                                onProfileUpdated: widget.onSessionUpdated,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$title is enabled natively.')),
                          );
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Preferences',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileMenuTile(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Modify name, phone & account info',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            userSession: userSession,
                            onProfileUpdated: widget.onSessionUpdated,
                          ),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.gavel_rounded,
                    title: 'Terms & Privacy Policy',
                    subtitle: 'LANDSFY legal agreements',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text('Terms & Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              const SizedBox(height: 12),
                              const Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    'Welcome to LANDSFY. By accessing or using our mobile application services, you agree to comply with and be bound by the following terms and privacy practices:\n\n'
                                    '1. User Privacy: Your personal data, email, and contact information will only be used to facilitate property buy, sell, and rent connections.\n\n'
                                    '2. Verified Listings: All properties posted on LANDSFY must contain accurate location, pricing, and ownership information.\n\n'
                                    '3. Data Protection: We do not share or sell user data to unverified third parties.\n\n'
                                    '4. Account Safety: Users are responsible for maintaining the confidentiality of their credentials.',
                                    style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMain),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: onLogout,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
