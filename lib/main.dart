import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConstants.init();
  runApp(const LandsfyApp());
}

class LandsfyApp extends StatelessWidget {
  const LandsfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'landsfy.com',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
