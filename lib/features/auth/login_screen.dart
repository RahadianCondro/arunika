// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to dashboard on successful login
          AppRoutes.navigateTo(context, AppRoutes.dashboard, replace: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/Arunika.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )

                  ).animate().fade().scale(),

                  
                  SizedBox(height: AppDimensions.spacing4),
                  
                  // Login title
                  Text(
                    AppStrings.login,
                    style: Theme.of(context).textTheme.displayMedium,
                  ).animate().fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing8),
                  
                  // Email field
                  AppTextField(
                    label: AppStrings.email,
                    hint: 'your.email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ).animate(delay: 100.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing4),
                  
                  // Password field
                  AppTextField(
                    label: AppStrings.password,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.gray60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ).animate(delay: 200.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing4),
                  
                  // Remember me and Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Text(
                            AppStrings.rememberMe,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password
                        },
                        child: Text(AppStrings.forgotPassword),
                      ),
                    ],
                  ).animate(delay: 300.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Login button
                  PrimaryButton(
                    text: AppStrings.login,
                    onPressed: _login,
                    isLoading: _isLoading,
                  ).animate(delay: 400.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Or divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.gray40,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppColors.gray60,
                            fontSize: AppDimensions.small,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.gray40,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ).animate(delay: 500.ms).fade(),
                  
                  SizedBox(height: AppDimensions.spacing6),
                  
                  // Google sign in
                  OutlinedButton.icon(
                    onPressed: () {
                      // Handle Google sign in
                    },
                    icon: Image.asset(
                      'assets/icons/google.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(AppStrings.continueWithGoogle),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spacing4,
                        horizontal: AppDimensions.spacing4,
                      ),
                    ),
                  ).animate(delay: 600.ms).fade().slideY(begin: 0.5, end: 0),
                  
                  SizedBox(height: AppDimensions.spacing8),
                  
                  // Register option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          AppRoutes.navigateTo(context, AppRoutes.register, replace: true);
                        },
                        child: Text(AppStrings.register),
                      ),
                    ],
                  ).animate(delay: 700.ms).fade(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}