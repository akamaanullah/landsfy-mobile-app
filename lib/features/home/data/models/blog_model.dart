class BlogModel {
  final String title;
  final String slug;
  final String? excerpt;
  final String category;
  final String? imageUrl;
  final String createdAt;

  BlogModel({
    required this.title,
    required this.slug,
    this.excerpt,
    required this.category,
    this.imageUrl,
    required this.createdAt,
  });

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    final cleanPath = imageUrl!.startsWith('/') ? imageUrl!.substring(1) : imageUrl;
    return 'https://landsfy.com/$cleanPath';
  }

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString(),
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  /// Formatted date e.g "June 6, 2026"
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}
