import 'property_model.dart';
import 'blog_model.dart';

class HomeData {
  final List<PropertyModel> featuredProperties;
  final List<BlogModel> latestBlogs;
  final List<dynamic> cities;
  final List<dynamic> categories;
  final List<dynamic> subtypes;
  final Map<String, dynamic> browseData;
  final Map<String, int> counts;

  HomeData({
    required this.featuredProperties,
    required this.latestBlogs,
    required this.cities,
    required this.categories,
    required this.subtypes,
    required this.browseData,
    required this.counts,
  });

  factory HomeData.fromJson(Map<String, dynamic> data) {
    // Parse featured properties
    final rawProps = data['featured_properties'] as List<dynamic>? ?? [];
    final properties = rawProps
        .map((p) => PropertyModel.fromJson(p as Map<String, dynamic>))
        .toList();

    // Parse blogs
    final rawBlogs = data['latest_blogs'] as List<dynamic>? ?? [];
    final blogs = rawBlogs
        .map((b) => BlogModel.fromJson(b as Map<String, dynamic>))
        .toList();

    // Parse counts
    final rawCounts = data['counts'] as Map<String, dynamic>? ?? {};
    final counts = <String, int>{
      'homes': int.tryParse(rawCounts['homes']?.toString() ?? '0') ?? 0,
      'plots': int.tryParse(rawCounts['plots']?.toString() ?? '0') ?? 0,
      'commercial': int.tryParse(rawCounts['commercial']?.toString() ?? '0') ?? 0,
    };

    return HomeData(
      featuredProperties: properties,
      latestBlogs: blogs,
      cities: data['cities'] as List<dynamic>? ?? [],
      categories: data['categories'] as List<dynamic>? ?? [],
      subtypes: data['subtypes'] as List<dynamic>? ?? [],
      browseData: data['browse_data'] as Map<String, dynamic>? ?? {},
      counts: counts,
    );
  }
}
