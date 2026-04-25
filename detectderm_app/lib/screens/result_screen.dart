import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  // ── Get color based on disease ───────────
  Color _getDiseaseColor(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return Colors.red;
      case 'Benign Keratosis':
        return Colors.blue;
      case 'Melanocytic Nevus':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ── Get icon based on disease ────────────
  IconData _getDiseaseIcon(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return Icons.warning_amber_rounded;
      case 'Benign Keratosis':
        return Icons.check_circle_rounded;
      case 'Melanocytic Nevus':
        return Icons.circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  // ── Warning color ────────────────────────
  Color _getWarningColor(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return Colors.red;
      case 'Benign Keratosis':
        return Colors.blue;
      case 'Melanocytic Nevus':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ── Warning icon ─────────────────────────
  IconData _getWarningIcon(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return Icons.warning_amber_rounded;
      case 'Benign Keratosis':
        return Icons.info_rounded;
      case 'Melanocytic Nevus':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  // ── Warning text ─────────────────────────
  String _getWarningText(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return '⚠️ यो गम्भीर रोग हो! तुरुन्तै डाक्टरकहाँ जानुहोस्!';
      case 'Benign Keratosis':
        return 'ℹ️ सामान्य अवस्था हो तर check गराउनुहोस्।';
      case 'Melanocytic Nevus':
        return '✅ सामान्य तिल हो, तर परिवर्तन भएमा ध्यान दिनुहोस्।';
      default:
        return 'डाक्टरसँग परामर्श लिनुहोस्।';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diseaseEn = result['disease_en'] ?? 'Unknown';
    final diseaseNp = result['disease_np'] ?? 'अज्ञात';
    final adviceNp = result['advice_np'] ?? '';
    final confidence = result['confidence'] ?? '0%';
    final scanId = result['scan_id'] ?? 0;
    final isOffline = result['is_offline'] ?? false;

    // skip feedback flag
    final skipFeedback = result['skip_feedback'] ?? false;

    final diseaseColor = _getDiseaseColor(diseaseEn);

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        automaticallyImplyLeading: false,
        title: const Text(
          'Detection Result',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Offline Badge ───────────────
            if (isOffline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Offline Mode',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),

            // ── Disease Card ────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: diseaseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: diseaseColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    _getDiseaseIcon(diseaseEn),
                    size: 60,
                    color: diseaseColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    diseaseNp,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: diseaseColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(diseaseEn),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: diseaseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: $confidence',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Advice ───────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(adviceNp),
            ),

            const SizedBox(height: 16),

            // ── Warning Box ──────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getWarningColor(diseaseEn).withOpacity(0.1),
                border: Border.all(color: _getWarningColor(diseaseEn)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getWarningIcon(diseaseEn),
                    color: _getWarningColor(diseaseEn),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getWarningText(diseaseEn),
                      style: TextStyle(
                        color: _getWarningColor(diseaseEn),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Disclaimer ───────────────────
            const Text(
              '⚠️ AI result मात्र हो, डाक्टरसँग confirm गर्नुहोस्।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ──  CONDITIONAL FEEDBACK BUTTON ──
            if (!skipFeedback) ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/feedback',
                      arguments: scanId,
                    );
                  },
                  icon: const Icon(Icons.star_rate_rounded),
                  label: const Text(
                    'Feedback दिनुस्',
                    style: TextStyle(
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
            ],

            // ── Scan Again Button ────────────
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('अर्को Scan गर्नुस्'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}