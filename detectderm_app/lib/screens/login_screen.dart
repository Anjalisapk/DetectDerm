import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ── Login ─────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.containsKey('user_id')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', result['user_id']);
      await prefs.setString('user_name', result['name']);
      await prefs.setString('user_email', result['email']);
      await prefs.setBool('is_guest', false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Login failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Guest login ───────────────────────────
  Future<void> _continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    await prefs.remove('user_id');
    await prefs.setString('user_name', 'Guest');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  // ── Forgot password dialog ────────────────
  void _showForgotPassword() {
    final resetEmailController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    // Password checks
    bool hasMinLength() =>
        newPassController.text.length >= 8;
    bool hasUppercase() =>
        newPassController.text.contains(RegExp(r'[A-Z]'));
    bool hasLowercase() =>
        newPassController.text.contains(RegExp(r'[a-z]'));
    bool hasNumber() =>
        newPassController.text.contains(RegExp(r'[0-9]'));
    bool hasSpecial() => newPassController.text
        .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool isStrong() =>
        hasMinLength() &&
        hasUppercase() &&
        hasLowercase() &&
        hasNumber() &&
        hasSpecial();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.lock_reset,
                    color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text('Password Reset'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'तपाईंको registered email र नयाँ password हाल्नुस्:',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextField(
                    controller: resetEmailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Registered Email',
                      hintText: 'example@gmail.com',
                      prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF2E7D32),
                          size: 20),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2),
                      ),
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // New password
                  TextField(
                    controller: newPassController,
                    obscureText: obscureNew,
                    onChanged: (_) =>
                        setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'नयाँ Password',
                      prefixIcon: const Icon(Icons.lock,
                          color: Color(0xFF2E7D32),
                          size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () => setDialogState(
                            () => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2),
                      ),
                      isDense: true,
                    ),
                  ),

                  // Password requirements
                  if (newPassController.text.isNotEmpty)
                    ...[
                    const SizedBox(height: 8),
                    _buildMiniRequirement(
                        '8+ characters', hasMinLength()),
                    _buildMiniRequirement(
                        'Uppercase (A-Z)', hasUppercase()),
                    _buildMiniRequirement(
                        'Lowercase (a-z)', hasLowercase()),
                    _buildMiniRequirement(
                        'Number (0-9)', hasNumber()),
                    _buildMiniRequirement(
                        'Special (!@#\$)', hasSpecial()),
                  ],

                  const SizedBox(height: 12),

                  // Confirm password
                  TextField(
                    controller: confirmPassController,
                    obscureText: obscureConfirm,
                    onChanged: (_) =>
                        setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Password Confirm गर्नुस्',
                      prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF2E7D32),
                          size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () => setDialogState(
                            () => obscureConfirm =
                                !obscureConfirm),
                      ),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2),
                      ),
                      isDense: true,
                      // Match check
                      suffixText: confirmPassController
                                  .text.isNotEmpty &&
                              confirmPassController.text ==
                                  newPassController.text
                          ? '✅'
                          : confirmPassController
                                  .text.isNotEmpty
                              ? '❌'
                              : null,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validation
                        if (resetEmailController.text
                            .isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Text('Email हाल्नुस्!'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        if (!isStrong()) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Strong password हाल्नुस्!'),
                            backgroundColor: Colors.orange,
                          ));
                          return;
                        }
                        if (newPassController.text !=
                            confirmPassController.text) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Password match भएन!'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        setDialogState(
                            () => isLoading = true);

                        // API call
                        final res = await ApiService
                            .resetPassword(
                          resetEmailController.text
                              .trim(),
                          newPassController.text.trim(),
                        );

                        setDialogState(
                            () => isLoading = false);

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              res.containsKey('error')
                                  ? res['error']
                                  : 'Password reset सफल भयो! Login गर्नुस्',
                            ),
                            backgroundColor: res
                                    .containsKey('error')
                                ? Colors.red
                                : Colors.green,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Reset गर्नुस्'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Mini requirement widget for dialog ────
  Widget _buildMiniRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            isMet
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 14,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet
                  ? Colors.green[700]
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 60),

              // ── Logo ──────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius:
                        BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                      Icons.health_and_safety,
                      size: 55,
                      color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'DetectDerm',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),

              const Center(
                child: Text(
                  'छाला रोग पहिचान प्रणाली',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              // ── Email ─────────────────────
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@gmail.com',
                  prefixIcon: const Icon(Icons.email,
                      color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email हाल्नुस्!';
                  }
                  if (!value.contains('@')) {
                    return 'Valid email हाल्नुस्!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Password ──────────────────
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password हाल्नुस्',
                  prefixIcon: const Icon(Icons.lock,
                      color: Color(0xFF2E7D32)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() =>
                        _obscurePassword =
                            !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password हाल्नुस्!';
                  }
                  if (value.length < 8) {
                    return 'Password कम्तीमा 8 characters!'; // ← 6→8
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // ── Forgot password ───────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Password बिर्सनुभयो?',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Login button ──────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          'Login गर्नुस्',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Divider ───────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12),
                    child: Text('वा',
                        style: TextStyle(
                            color: Colors.grey[600])),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // ── Guest button ──────────────
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _continueAsGuest,
                  icon: const Icon(Icons.person_outline,
                      color: Color(0xFF2E7D32)),
                  label: const Text(
                    'Guest को रूपमा प्रवेश गर्नुस्',
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Guest info ────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Guest को रूपमा scan history save हुँदैन।',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Register link ─────────────
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text('Account छैन? ',
                      style:
                          TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/register'),
                    child: const Text(
                      'Register गर्नुस्',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}