import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/google_sign_in_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<Alignment>(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<Alignment>(
          begin: Alignment.topRight,
          end: Alignment.centerRight,
        ),
      ),
    ]).animate(_backgroundAnimationController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<Alignment>(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<Alignment>(
          begin: Alignment.bottomLeft,
          end: Alignment.centerLeft,
        ),
      ),
    ]).animate(_backgroundAnimationController);
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
                colors: [
                  AppColors.navy,
                  AppColors.accent.withOpacity(0.8),
                  AppColors.navy.withOpacity(0.9),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with glass effect
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              AppIcons.wallet,
                              width: 48,
                              height: 48,
                              colorFilter: ColorFilter.mode(
                                AppColors.accent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Chit Tracker',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Track your chits efficiently',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                        ),
                        const SizedBox(height: 48),
                        // Features list
                        Column(
                          children: [
                            _buildFeatureItem(
                              context,
                              Icons.track_changes_outlined,
                              'Track Income & Expenses',
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              context,
                              Icons.group_outlined,
                              'Collaborate with Others',
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        GoogleSignInButton(
                          onSuccess: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            );
                          },
                          onError: (error) {
                            // Additional error handling if needed
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
