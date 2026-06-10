import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'stat_card.dart';
import 'profile_menu_tile.dart';

class RoleDashboardView extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onLogout;

  const RoleDashboardView({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final roles = ['Buyer', 'Seller', 'Agent', 'Agency Owner', 'Admin'];

    final Map<String, String> roleSubtitles = {
      'Buyer': 'Premium Home Buyer',
      'Seller': 'Individual Property Seller',
      'Agent': 'Certified Landsfy Agent',
      'Agency Owner': 'Agency Principal Owner',
      'Admin': 'System Administrator',
    };

    final Map<String, List<Map<String, dynamic>>> roleStats = {
      'Buyer': [
        {'value': '12', 'label': 'Saved Listings', 'icon': Icons.favorite_rounded, 'color': Colors.red},
        {'value': '04', 'label': 'Search Alerts', 'icon': Icons.notifications_active_rounded, 'color': Colors.amber},
        {'value': '06', 'label': 'Agents Messaged', 'icon': Icons.contact_mail_rounded, 'color': Colors.teal},
        {'value': '45', 'label': 'Viewed History', 'icon': Icons.history_rounded, 'color': Colors.blueGrey},
      ],
      'Seller': [
        {'value': '03', 'label': 'Listed Properties', 'icon': Icons.home_rounded, 'color': AppColors.primary},
        {'value': '1.2k', 'label': 'Total Views', 'icon': Icons.visibility_rounded, 'color': Colors.blue},
        {'value': '18', 'label': 'Buyer Inquiries', 'icon': Icons.chat_bubble_rounded, 'color': Colors.green},
        {'value': '05', 'label': 'Closed Deals', 'icon': Icons.handshake_rounded, 'color': Colors.orange},
      ],
      'Agent': [
        {'value': '15', 'label': 'Active Clients', 'icon': Icons.people_alt_rounded, 'color': Colors.indigo},
        {'value': '08', 'label': 'My Listings', 'icon': Icons.business_center_rounded, 'color': AppColors.primary},
        {'value': '32', 'label': 'Leads & Inquiries', 'icon': Icons.question_answer_rounded, 'color': Colors.green},
        {'value': 'PKR 4.5L', 'label': 'Est. Commission', 'icon': Icons.payments_rounded, 'color': Colors.amber},
      ],
      'Agency Owner': [
        {'value': '12', 'label': 'Active Agents', 'icon': Icons.supervised_user_circle_rounded, 'color': Colors.blue},
        {'value': '48', 'label': 'Agency Listings', 'icon': Icons.home_work_rounded, 'color': AppColors.primary},
        {'value': '120', 'label': 'Total Leads', 'icon': Icons.campaign_rounded, 'color': Colors.teal},
        {'value': 'PKR 18.5L', 'label': 'Total Revenue', 'icon': Icons.monetization_on_rounded, 'color': Colors.green},
      ],
      'Admin': [
        {'value': '2,450', 'label': 'Total Users', 'icon': Icons.people_rounded, 'color': Colors.purple},
        {'value': '14', 'label': 'Pending Approvals', 'icon': Icons.pending_actions_rounded, 'color': Colors.amber},
        {'value': '1,820', 'label': 'Active Listings', 'icon': Icons.check_circle_rounded, 'color': Colors.green},
        {'value': '03', 'label': 'Reports Flagged', 'icon': Icons.report_problem_rounded, 'color': Colors.red},
      ],
    };

    final Map<String, List<Map<String, dynamic>>> roleActions = {
      'Buyer': [
        {'title': 'Saved Searches', 'subtitle': 'Manage your saved search filters', 'icon': Icons.saved_search_rounded},
        {'title': 'Property Alerts', 'subtitle': 'Manage alert preferences for listings', 'icon': Icons.notifications_active_outlined},
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
        {'title': 'Moderation Queue', 'subtitle': 'Review and approve pending listings', 'icon': Icons.rule_folder_rounded},
        {'title': 'User Management', 'subtitle': 'Approve or block buyers, sellers and agents', 'icon': Icons.manage_accounts_rounded},
        {'title': 'Property Verification', 'subtitle': 'Verify documents and titles of listings', 'icon': Icons.verified_user_rounded},
        {'title': 'Global Configuration', 'subtitle': 'Configure system limits and values', 'icon': Icons.admin_panel_settings_rounded},
        {'title': 'Audit Logs', 'subtitle': 'Monitor administrator and system actions', 'icon': Icons.receipt_long_rounded},
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
            // Role Selector Chips
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: roles.map((role) {
                    final isSelected = selectedRole == role;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => onRoleChanged(role),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primarySoft : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

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
                      child: Image.network(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Uzair Ali',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'uzair@landsfy.com',
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
                    return ProfileMenuTile(
                      icon: act['icon'] as IconData,
                      title: act['title'].toString(),
                      subtitle: act['subtitle'].toString(),
                      onTap: () {},
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
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Alerts, updates & listings info',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.gavel_rounded,
                    title: 'Terms & Privacy Policy',
                    subtitle: 'Landsfy legal agreements',
                    onTap: () {},
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
