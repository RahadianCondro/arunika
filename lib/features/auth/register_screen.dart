import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arunika/data/repositories/auth_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  final _authRepo = AuthRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _authRepo.sendEmailVerification();

      if (!mounted) return;
      AppRoutes.navigateTo(context, AppRoutes.verifyEmail, replace: true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Gagal mendaftar'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.register)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spacing6),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              AppTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ).animate().fade().slideY(begin: 0.5),

              const SizedBox(height: 16),

              // Email
              AppTextField(
                label: AppStrings.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your email';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ).animate(delay: 100.ms).fade().slideY(begin: 0.5),

              const SizedBox(height: 16),

              // Password
              AppTextField(
                label: AppStrings.password,
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) =>
                    value == null || value.length < 6 ? 'Minimal 6 karakter' : null,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).animate(delay: 200.ms).fade().slideY(begin: 0.5),

              const SizedBox(height: 16),

              // Confirm Password
              AppTextField(
                label: AppStrings.confirmPassword,
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ).animate(delay: 300.ms).fade().slideY(begin: 0.5),

              const SizedBox(height: 16),

              // Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  ),
                  const Expanded(child: Text('Saya menyetujui syarat & ketentuan')),
                ],
              ),

              const SizedBox(height: 24),

              // Button
              PrimaryButton(
                text: AppStrings.register,
                onPressed: _register,
                isLoading: _isLoading,
              ).animate(delay: 400.ms).fade().slideY(begin: 0.5),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () =>
                    AppRoutes.navigateTo(context, AppRoutes.login),
                child: Text(AppStrings.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
