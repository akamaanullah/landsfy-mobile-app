import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static String baseUrl = 'https://landsfy.com';

  // Dynamic endpoints
  static String get homeData => '$baseUrl/includes/api/website/home_data.php';
  static String get propertiesData => '$baseUrl/includes/api/website/properties_data.php';
  static String get propertyDetail => '$baseUrl/includes/api/website/property_detail_data.php';
  static String get agenciesData => '$baseUrl/includes/api/website/agencies_data.php';
  static String get agencyDetail => '$baseUrl/includes/api/website/agency_detail_data.php';
  static String get agentsData => '$baseUrl/includes/api/website/agents_data.php';
  static String get agentDetail => '$baseUrl/includes/api/website/agent_detail_data.php';
  static String get blogData => '$baseUrl/includes/api/website/blog_data.php';
  static String get blogDetail => '$baseUrl/includes/api/website/blog_detail_data.php';
  static String get trackInteraction => '$baseUrl/includes/api/website/track_interaction.php';
  
  // Auth endpoints
  static String get login => '$baseUrl/includes/api/website/login.php';
  static String get register => '$baseUrl/includes/api/website/register.php';

  // Custom app-api endpoints
  static String get appLogin => '$baseUrl/app-api/login.php';
  static String get appRegister => '$baseUrl/app-api/register.php';
  static String get appStats => '$baseUrl/app-api/dashboard_stats.php';
  static String get appApprovals => '$baseUrl/app-api/get_approvals.php';
  static String get appUpdateStatus => '$baseUrl/app-api/update_status.php';
  static String get appListings => '$baseUrl/app-api/get_listings.php';
  static String get appLeads => '$baseUrl/app-api/get_leads.php';
  static String get appAgents => '$baseUrl/app-api/get_agents.php';
  static String get appRemoveAgent => '$baseUrl/app-api/remove_agent.php';
  static String get appAddProperty => '$baseUrl/app-api/add_property.php';
  static String get appUpdateProfile => '$baseUrl/app-api/update_profile.php';
  static String get appUsers => '$baseUrl/app-api/get_users.php';
  static String get appUpdateUserStatus => '$baseUrl/app-api/update_user_status.php';
  static String get appAgencies => '$baseUrl/app-api/get_agencies.php';
  static String get appCities => '$baseUrl/app-api/get_cities.php';
  static String get appAmenities => '$baseUrl/app-api/get_amenities.php';

  // Initialize from saved preference
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('custom_base_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      baseUrl = savedUrl;
    }
  }

  // Save and set new base url
  static Future<void> saveBaseUrl(String url) async {
    baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_base_url', url);
  }
}
