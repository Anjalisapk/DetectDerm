import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result; // Result data from prediction

  const ResultScreen({super.key, required this.result});

  // ── Get color based on disease ───────────
  Color _getDiseaseColor(String diseaseEn) {
    switch (diseaseEn) {
      case 'Melanoma':
        return Colors.red;
      case 'Actinic Keratosis':
        return Colors.orange;
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
      case 'Actinic Keratosis':
        return Icons.wb_sunny_rounded;
      case 'Benign Keratosis':
        return Icons.check_circle_rounded;
      case 'Melanocytic Nevus':
        return Icons.circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract result data
    final diseaseEn = result['disease_en'] ?? 'Unknown';
    final diseaseNp = result['disease_np'] ?? 'अज्ञात';
    final adviceNp = result['advice_np'] ?? '';
    final confidence = result['confidence'] ?? '0%';
    final scanId = result['scan_id'] ?? 0;
    final isOffline = result['is_offline'] ?? false;

    final diseaseColor = _getDiseaseColor(diseaseEn);

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ── App Bar ───────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        automaticallyImplyLeading: false,
        title: const Text(
          'Detection Result',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Home button
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

            // ── Offline Badge ─────────────────
            if (isOffline)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Offline Mode — TFLite model use भयो',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Disease Result Card ───────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: diseaseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: diseaseColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [

                  // Disease icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: diseaseColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDiseaseIcon(diseaseEn),
                      size: 45,
                      color: diseaseColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nepali disease name
                  Text(
                    diseaseNp,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: diseaseColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // English disease name
                  Text(
                    diseaseEn,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Confidence score
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: diseaseColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: $confidence',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Advice Card ───────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Advice header
                  Row(
                    children: [
                      Icon(Icons.medical_information,
                          color: diseaseColor, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'विस्तृत जानकारी',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Advice text
                  Text(
                    adviceNp,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Warning for Melanoma ──────────
            if (diseaseEn == 'Melanoma')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠️ यो गम्भीर रोग हो! तुरुन्तै '
                        'छालाविज्ञ डाक्टरकहाँ जानुहोस्!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Disclaimer ────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '⚠️ यो app AI आधारित छ — '
                'final diagnosis को लागि डाक्टरकहाँ जानुहोस्।',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // ── Feedback Button ───────────────
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

            // ── Scan Again Button ─────────────
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text(
                  'अर्को Scan गर्नुस्',
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}