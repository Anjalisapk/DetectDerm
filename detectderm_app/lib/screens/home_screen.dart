import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Guest';
  bool _isGuest = true;
  int? _userId;
  bool _isOnline = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkOnline();
  }

  // ── Check internet connection ─────────────
  Future<void> _checkOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty) {
        setState(() => _isOnline = true);
      }
    } catch (_) {
      setState(() => _isOnline = false);
    }
  }

  // ── Load user info ────────────────────────
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Guest';
      _isGuest = prefs.getBool('is_guest') ?? true;
      _userId = prefs.getInt('user_id');
    });
  }

  // ── Pick from camera ──────────────────────
  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      Navigator.pushNamed(
          context, '/preview', arguments: image.path);
    }
  }

  // ── Pick from gallery ─────────────────────
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      Navigator.pushNamed(
          context, '/preview', arguments: image.path);
    }
  }

  // ── Logout ────────────────────────────────
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content:
            const Text('के तपाईं logout गर्न चाहनुहुन्छ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs =
                  await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacementNamed(
                  context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.health_and_safety,
                color: Colors.white),
            SizedBox(width: 8),
            Text(
              'DetectDerm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Online/Offline indicator
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              _isOnline ? Icons.wifi : Icons.wifi_off,
              color: _isOnline
                  ? Colors.greenAccent
                  : Colors.orange,
              size: 20,
            ),
          ),
          // History (registered only)
          if (!_isGuest)
            IconButton(
              icon: const Icon(Icons.history,
                  color: Colors.white),
              onPressed: () =>
                  Navigator.pushNamed(context, '/history'),
              tooltip: 'History',
            ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout,
                color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 10),

            // ── Welcome Card ──────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.white.withOpacity(0.3),
                    child: Icon(
                      _isGuest
                          ? Icons.person_outline
                          : Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'नमस्ते, $_userName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isGuest
                              ? _isOnline
                                  ? 'Guest Mode — History save हुँदैन'
                                  : 'Offline Guest Mode'
                              : 'Registered User ✅',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isGuest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Guest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Offline Banner ────────────────
            if (!_isOnline)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Mode — TFLite model use हुन्छ। Scan history save हुँदैन।',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isOnline) const SizedBox(height: 12),

            // ── Title ─────────────────────────
            const Text(
              'छाला रोग पहिचान गर्नुस्',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'तलका बटनहरूबाट छालाको photo खिच्नुस् वा छान्नुस्',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ── Camera Button ─────────────────
            SizedBox(
              height: 130,
              child: ElevatedButton(
                onPressed: _pickFromCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48),
                    SizedBox(height: 10),
                    Text(
                      'Camera बाट Photo खिच्नुस्',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'छालाको नजिकबाट photo खिच्नुस्',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Gallery Button ────────────────
            SizedBox(
              height: 130,
              child: OutlinedButton(
                onPressed: _pickFromGallery,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 48,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Gallery बाट Photo छान्नुस्',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'पहिले खिचेको photo छान्नुस्',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Disease list ──────────────────
            const Text(
              'पहिचान गर्न सकिने रोगहरू:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            _buildDiseaseCard('मेलानोमा', 'Melanoma',
                Icons.warning_amber, Colors.red[100]!, Colors.red),
            _buildDiseaseCard('सामान्य केराटोसिस',
                'Benign Keratosis', Icons.check_circle,
                Colors.blue[100]!, Colors.blue),
            _buildDiseaseCard('मेलानोसाइटिक नेभस (तिल)',
                'Melanocytic Nevus', Icons.circle,
                Colors.green[100]!, Colors.green),

            const SizedBox(height: 20),

            // ── Register prompt (Online + Guest मात्र) ─
            if (_isGuest && _isOnline)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Account बनाउनुस्!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Account बनाएमा scan history save हुन्छ र पछि हेर्न सकिन्छ।',
                      style: TextStyle(
                          fontSize: 13, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, '/register'),
                        icon: const Icon(Icons.person_add,
                            size: 18),
                        label:
                            const Text('Register गर्नुस्'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Disease card widget ───────────────────
  Widget _buildDiseaseCard(String nameNp, String nameEn,
      IconData icon, Color bgColor, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nameNp,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(nameEn,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}