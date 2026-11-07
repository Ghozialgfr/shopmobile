import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  bool _setupLoading = false;
  Map<String, dynamic>? _setup;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _login() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Masukkan 6 digit kode authenticator');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.login(code);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _clean(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSetup() async {
    setState(() {
      _setupLoading = true;
      _error = null;
    });
    try {
      final data = await AuthService.fetchSetup();
      if (!mounted) return;
      setState(() => _setup = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _clean(e));
    } finally {
      if (mounted) setState(() => _setupLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pinkMedium.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: AppColors.pink,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masukkan kode 6 digit dari Google Authenticator',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSoft),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _codeCtrl,
                      enabled: !_loading,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '000000',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        if (_error != null) setState(() => _error = null);
                        if (v.length == 6 && !_loading) _login();
                      },
                      onSubmitted: (_) => _login(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_setup == null)
                      TextButton(
                        onPressed: _setupLoading ? null : _loadSetup,
                        child: Text(
                          _setupLoading
                              ? 'Memuat...'
                              : 'Belum setup authenticator? Tampilkan QR',
                          style: const TextStyle(color: AppColors.pink),
                        ),
                      )
                    else
                      _buildSetup(_setup!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup(Map<String, dynamic> s) {
    final url = (s['otp_auth_url'] ?? '').toString();
    return Column(
      children: [
        const SizedBox(height: 8),
        if (url.isNotEmpty) QrImageView(data: url, size: 200),
        const SizedBox(height: 8),
        Text(
          'Issuer: ${s['issuer']}\nAkun: ${s['account']}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
        ),
        const SizedBox(height: 4),
        SelectableText(
          'Secret: ${s['secret']}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.text, fontSize: 12),
        ),
      ],
    );
  }
}
