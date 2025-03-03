import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';

class GoogleSignInButton extends StatefulWidget {
  final Function onSuccess;
  final Function? onError;

  const GoogleSignInButton({
    Key? key,
    required this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _buttonAnimationController.forward();

      // Use the AuthProvider to sign in
      await context.read<AuthProvider>().signInWithGoogle();

      if (!mounted) return;

      // Call the success callback
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      // Call error callback if provided
      if (widget.onError != null) {
        widget.onError!(e);
      }

      await _buttonAnimationController.reverse();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: _isLoading
                ? null
                : (_) {
                    _buttonAnimationController.forward();
                  },
            onTapUp: _isLoading
                ? null
                : (_) {
                    _buttonAnimationController.reverse();
                  },
            onTapCancel: _isLoading
                ? null
                : () {
                    _buttonAnimationController.reverse();
                  },
            onTap: _isLoading ? null : _handleGoogleSignIn,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isLoading) ...[
                    Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sign in with Google',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ] else
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
