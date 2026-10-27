import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/visitor_management/di/injection.dart';
import 'features/visitor_management/presentation/bloc/visitor_bloc.dart';
import 'features/visitor_management/presentation/bloc/visitor_event.dart';
import 'features/visitor_management/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyInjection();
  runApp(const VisitorAppointmentApp());
}

class VisitorAppointmentApp extends StatelessWidget {
  const VisitorAppointmentApp({super.key});

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
        home: const MainNavigationScreen(),
      ),
    );
  }
}
