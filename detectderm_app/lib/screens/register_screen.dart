import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ── Password strength checks ──────────────
  bool get _hasMinLength =>
      _passwordController.text.length >= 8;
  bool get _hasUppercase =>
      _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase =>
      _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber =>
      _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passwordController.text
      .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  bool get _isPasswordStrong =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial;

  // ── Password strength score (0-5) ─────────
  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecial) score++;
    return score;
  }

  // ── Strength label ────────────────────────
  String get _strengthLabel {
    switch (_strengthScore) {
      case 0:
      case 1:
        return 'धेरै कमजोर (Very Weak)';
      case 2:
        return 'कमजोर (Weak)';
      case 3:
        return 'ठीकै (Fair)';
      case 4:
        return 'राम्रो (Good)';
      case 5:
        return 'धेरै राम्रो (Strong)';
      default:
        return '';
    }
  }

  // ── Strength color ────────────────────────
  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ── Register function ─────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPasswordStrong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password सबै requirements पूरा गर्नुस्!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.containsKey('user_id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text(' Registration सफल भयो! Login गर्नुस्'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['error'] ?? 'Registration failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'नयाँ Account बनाउनुस्',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 16),

              // ── Logo ──────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.person_add,
                      size: 45, color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'DetectDerm मा सामेल हुनुस्',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Name field ────────────────
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'पूरा नाम',
                  hintText: 'तपाईंको नाम लेख्नुस्',
                  prefixIcon: const Icon(Icons.person,
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
                    return 'नाम हाल्नुस्!';
                  }
                  if (value.trim().length < 2) {
                    return 'नाम कम्तीमा 2 अक्षर हुनुपर्छ!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Email field ───────────────
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
                  if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                      .hasMatch(value)) {
                    return 'Valid email हाल्नुस्!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Password field ────────────
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Strong password हाल्नुस्',
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
                  if (!_isPasswordStrong) {
                    return 'Password सबै requirements पूरा गर्नुस्!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ── Password strength bar ─────
              if (_passwordController.text.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Password strength: ',
                        style: TextStyle(fontSize: 12)),
                    Text(
                      _strengthLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _strengthColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _strengthScore / 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                        _strengthColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Password requirements ─────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password requirements:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement(
                      'कम्तीमा 8 characters',
                      _hasMinLength,
                    ),
                    _buildRequirement(
                      'Uppercase letter (A-Z)',
                      _hasUppercase,
                    ),
                    _buildRequirement(
                      'Lowercase letter (a-z)',
                      _hasLowercase,
                    ),
                    _buildRequirement(
                      'Number (0-9)',
                      _hasNumber,
                    ),
                    _buildRequirement(
                      'Special character (!@#\$%^&*)',
                      _hasSpecial,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Register button ───────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPasswordStrong
                            ? const Color(0xFF2E7D32)
                            : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          'Register गर्नुस्',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Login link ────────────────
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text('Already account छ? ',
                      style:
                          TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(
                            context, '/login'),
                    child: const Text(
                      'Login गर्नुस्',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Requirement row widget ────────────────
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isMet
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 16,
            color: isMet
                ? Colors.green
                : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? Colors.green[700]
                  : Colors.grey[600],
              fontWeight: isMet
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}