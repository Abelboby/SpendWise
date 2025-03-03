import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/space_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SpaceProvider>(
          create: (context) => SpaceProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? SpaceProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Income Tracker',
        theme: ThemeData(
          colorScheme: AppColors.realTheme,
          useMaterial3: true,
          fontFamily: 'Manrope',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w700),
            displayMedium: TextStyle(fontWeight: FontWeight.w700),
            displaySmall: TextStyle(fontWeight: FontWeight.w700),
            headlineLarge: TextStyle(fontWeight: FontWeight.w700),
            headlineMedium: TextStyle(fontWeight: FontWeight.w700),
            headlineSmall: TextStyle(fontWeight: FontWeight.w700),
            titleLarge: TextStyle(fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontWeight: FontWeight.w600),
            titleSmall: TextStyle(fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontWeight: FontWeight.w400),
            bodySmall: TextStyle(fontWeight: FontWeight.w400),
            labelLarge: TextStyle(fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontWeight: FontWeight.w500),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.navy.withOpacity(0.1),
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            toolbarTextStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              color: AppColors.lightGrey,
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (authProvider.isAuthenticated) {
              // Initialize providers with user ID
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final financeProvider =
                    Provider.of<FinanceProvider>(context, listen: false);
                financeProvider.initialize(authProvider.uid);

                final spaceProvider =
                    Provider.of<SpaceProvider>(context, listen: false);
                spaceProvider.initialize(authProvider.uid);
              });

              return const MainNavigationScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
