import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';

class BlogDetailScreen extends StatefulWidget {
  final String slug;

  const BlogDetailScreen({super.key, required this.slug});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _postData = {};
  List<dynamic> _relatedPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchBlogDetails();
  }

  @override
  void didUpdateWidget(covariant BlogDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slug != oldWidget.slug) {
      _fetchBlogDetails();
    }
  }

  Future<void> _fetchBlogDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/includes/api/website/blog_detail_data.php',
        queryParameters: {'slug': widget.slug},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> json = response.data is String
            ? throw Exception('API returned HTML instead of JSON')
            : response.data as Map<String, dynamic>;

        if (json['success'] == true && json['data'] != null) {
          if (mounted) {
            setState(() {
              _postData = json['data']['post'] as Map<String, dynamic>;
              _relatedPosts = json['data']['related'] as List<dynamic>? ?? [];
              _isLoading = false;
            });
          }
        } else {
          throw Exception(json['message']?.toString() ?? 'Failed to load article');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
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

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<p[^>]*>'), '\n\n')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .trim();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1546074177-ffedd79d494d?auto=format&fit=crop&w=800&q=80';
    }
    if (path.startsWith('http') || path.startsWith('https')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return 'https://landsfy.com/$clean';
  }

  String _getFormattedDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      final months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _postData['title']?.toString() ?? '';
    final category = _postData['category']?.toString() ?? 'General';
    final content = _postData['content']?.toString() ?? '';
    final imageUrl = _getImageUrl(_postData['image_url']?.toString());
    final date = _getFormattedDate(_postData['created_at']?.toString() ?? '');
    final authorName = _postData['author_name']?.toString() ?? 'Admin';
    final authorAvatar = _getImageUrl(_postData['author_img']?.toString());
    final readTime = _postData['read_time']?.toString() ?? '5';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isLoading ? 'Loading article...' : category,
          style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchBlogDetails, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Image
                      Container(
                        margin: const EdgeInsets.all(16),
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.bgLight),
                            errorWidget: (context, url, error) => Container(color: AppColors.bgLight, child: const Icon(Icons.newspaper_rounded)),
                          ),
                        ),
                      ),

                      // Meta details row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(authorAvatar),
                                  radius: 18,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authorName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.black),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$date • $readTime min read',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.border, height: 32),
                            
                            // Article text content
                            Text(
                              _stripHtml(content),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textMain,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 48),
                          ],
                        ),
                      ),

                      // Related Posts
                      if (_relatedPosts.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Related Articles',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.black),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            itemCount: _relatedPosts.length,
                            itemBuilder: (context, index) {
                              final related = _relatedPosts[index];
                              final relTitle = related['title']?.toString() ?? '';
                              final relSlug = related['slug']?.toString() ?? '';
                              final relImage = _getImageUrl(related['image_url']?.toString());
                              final relDate = _getFormattedDate(related['created_at']?.toString() ?? '');

                              return GestureDetector(
                                onTap: () {
                                  context.pushReplacementNamed('blog_detail', pathParameters: {'slug': relSlug});
                                },
                                child: Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: relImage,
                                          width: 80,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                relTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, height: 1.3),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                relDate,
                                                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ],
                  ),
                ),
    );
  }
}
