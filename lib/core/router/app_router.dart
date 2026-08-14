import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/property_details/presentation/property_details_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/blog_details/presentation/blog_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(
          initialFilters: state.uri.queryParameters.isNotEmpty 
              ? state.uri.queryParameters 
              : null,
        ),
      ),
      GoRoute(
        path: '/details',
        name: 'details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PropertyDetailsScreen(property: extra);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/blog/:slug',
        name: 'blog_detail',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          return BlogDetailScreen(slug: slug);
        },
      ),
    ],
  );
}
