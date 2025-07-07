// lib/features/auth/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../routes.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _canResendEmail = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  void _startResendCooldown() {
    setState(() {
      _canResendEmail = false;
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
        setState(() {
          _canResendEmail = true;
        });
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      if (!mounted) return;
      AppRoutes.navigateTo(context, AppRoutes.healthProfile, replace: true);
    } else {
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email belum diverifikasi.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verifikasi berhasil dikirim ulang.'),
            backgroundColor: AppColors.success,
          ),
        );
        _startResendCooldown();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim ulang email.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Kami telah mengirimkan email verifikasi.\nSilakan cek inbox Anda dan klik link verifikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Saya sudah verifikasi',
              onPressed: _isChecking ? () {} : _checkVerification,
              isLoading: _isChecking,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _canResendEmail ? _resendVerificationEmail : null,
              child: Text(
                _canResendEmail
                    ? 'Kirim ulang email verifikasi'
                    : 'Tunggu $_resendCountdown detik...',
                style: TextStyle(
                  color: _canResendEmail ? AppColors.primary : AppColors.gray60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
