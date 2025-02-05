import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/category_provider.dart';
import 'screens/home_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: ThemeData(
              colorScheme: appState.isFakeMode ? AppColors.fakeTheme : AppColors.realTheme,
              useMaterial3: true,
              cardTheme: CardTheme(
                color: appState.isFakeMode ? AppColors.fakeCardColor : AppColors.realCardColor,
                elevation: 2,
              ),
              textTheme: TextTheme(
                titleLarge: TextStyle(
                  color: appState.isFakeMode ? AppColors.fakeTextColor : AppColors.realTextColor,
                  fontWeight: FontWeight.bold,
                ),
                bodyLarge: TextStyle(
                  color: appState.isFakeMode ? AppColors.fakeTextColor : AppColors.realTextColor,
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
