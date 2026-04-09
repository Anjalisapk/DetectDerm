import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/api_service.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath; // Image path from home screen

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false; // Loading state

  // ── Analyze Image ────────────────────────
  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);

    // Get user info from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id'); // null if guest

    // Call predict (auto online/offline)
    final result = await ApiService.predict(
      widget.imagePath,
      userId: userId,
    );

    setState(() => _isAnalyzing = false);

    if (!mounted) return;
     // ── Not a skin disease ────────────────
    if (result['error'] == 'not_skin') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Icons.image_not_supported,
            color: Colors.orange,
            size: 48,
          ),
          title: const Text(
            'छाला रोग भेटिएन!',
            textAlign: TextAlign.center,
          ),
          content: Text(
            result['message'] ?? 'Clear photo खिच्नुस्!',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);  // Dialog बन्द
                  Navigator.pop(context);  // Home मा जान्छ
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('अर्को Photo खिच्नुस्'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    } 
    // Check for error
    if (result.containsKey('error') && result['error'] != 'offline') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Go to result screen with prediction data
    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ── App Bar ───────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Photo Preview',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [

          // ── Image Preview ─────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // ── Bottom Section ────────────────
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // Instruction text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'छालाको affected area स्पष्ट देखिनु पर्छ। '
                          'राम्रो photo भएमा सही result आउँछ।',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Analyze Button ────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeImage,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isAnalyzing
                          ? 'Analyzing...'
                          : 'Analyze गर्नुस्',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Retake Button ─────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'अर्को Photo छान्नुस्',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(
                        color: Color(0xFF2E7D32),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}