import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  final int scanId; // Scan ID from result screen

  const FeedbackScreen({super.key, required this.scanId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // State variables
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false; // Show success screen

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ── Submit Feedback ──────────────────────
  Future<void> _submitFeedback() async {
    // Rating check
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया Rating दिनुस्!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Save feedback to Flask API (online only)
    final result = await ApiService.saveFeedback(
      widget.scanId,
      _rating.toInt(),
      _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    // Show success screen regardless of online/offline
    setState(() => _isSubmitted = true);
  }

  // ── Get rating label ─────────────────────
  String _getRatingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'धेरै नराम्रो 😞';
      case 2:
        return 'नराम्रो 😕';
      case 3:
        return 'ठीकै छ 😐';
      case 4:
        return 'राम्रो 😊';
      case 5:
        return 'धेरै राम्रो 😄';
      default:
        return 'Rating छान्नुस्';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show success screen after submission
    if (_isSubmitted) {
      return _buildSuccessScreen(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ── App Bar ───────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        automaticallyImplyLeading: false,
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Skip button
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 20),

            // ── Header ────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.feedback_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'तपाईंको Feedback',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'यो app सुधार गर्न तपाईंको feedback\nहामीलाई धेरै महत्वपूर्ण छ!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Rating Card ───────────────────
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
                children: [

                  const Text(
                    'App कस्तो लाग्यो?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Star rating bar
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    maxRating: 5,
                    itemCount: 5,
                    itemSize: 48,
                    itemPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() => _rating = rating);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Rating label
                  Text(
                    _getRatingLabel(_rating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _rating == 0
                          ? Colors.grey
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Comment Card ──────────────────
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

                  const Text(
                    'Comment (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText:
                          'तपाईंको सुझाव वा comment लेख्नुस्...',
                      hintStyle:
                          TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2E7D32),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Submit Button ─────────────────
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Feedback Submit गर्नुस्',
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

            // ── Skip Button ───────────────────
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text(
                  'Skip गर्नुस्',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
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

  // ── Success Screen ───────────────────────
  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Success icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'धन्यवाद! (Thank you)',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'तपाईंको Feedback\nसफलतापूर्वक Submit भयो!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Star rating display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 36,
                  color: index < _rating
                      ? Colors.amber
                      : Colors.white30,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Home button
            SizedBox(
              width: 200,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text(
                  'Home मा जानुस्',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}