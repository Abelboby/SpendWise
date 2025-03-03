import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'spaces_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../providers/finance_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SpacesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // Reset space context when switching away from Spaces tab
    if (_selectedIndex == 1 && index != 1) {
      final financeProvider = context.read<FinanceProvider>();
      financeProvider.setCurrentSpace(null);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.darkGrey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.wallet,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.darkGrey,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.wallet,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            label: 'Incomes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.group_work_outlined),
            label: 'Spaces',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
