import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/visitor_management/di/injection.dart';
import 'features/visitor_management/presentation/bloc/visitor_bloc.dart';
import 'features/visitor_management/presentation/bloc/visitor_event.dart';
import 'features/visitor_management/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyInjection();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(VisitorAppointmentApp(isLoggedIn: isLoggedIn));
}

class VisitorAppointmentApp extends StatelessWidget {
  final bool isLoggedIn;

  const VisitorAppointmentApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VisitorBloc>(
          create: (_) => sl<VisitorBloc>()..add(const LoadVisitorsEvent()),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
      ),
    );
  }
}
