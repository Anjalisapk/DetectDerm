import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ── Load scan history from API ────────────
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name') ?? '';

    setState(() => _userName = userName);

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final history = await ApiService.getHistory(userId);

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  // ── Get color based on disease ────────────
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

  // ── Get icon based on disease ─────────────
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

  // ── Get confidence color ──────────────────
  Color _getConfidenceColor(String confidence) {
    final conf = double.tryParse(
            confidence.replaceAll('%', '')) ??
        0;
    if (conf >= 80) return Colors.green;
    if (conf >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ── App Bar ───────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadHistory();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: Column(
        children: [

          // ── Header Card ───────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'कुल ${_history.length} scan(s)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── History List ──────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(height: 16),
                        Text('Loading history...'),
                      ],
                    ),
                  )
                : _history.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: const Color(0xFF2E7D32),
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(
                                _history[index], index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ── Empty state widget ────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'कुनै scan history छैन!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'पहिले छालाको photo scan गर्नुस्',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, '/home');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan गर्नुस्'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── History card widget ───────────────────
  Widget _buildHistoryCard(
      Map<String, dynamic> item, int index) {
    final diseaseEn = item['disease_en'] ?? 'Unknown';
    final diseaseNp = item['disease_np'] ?? '';
    final confidence = item['confidence'] ?? '0%';
    final scannedAt = item['scanned_at'] ?? '';
    final color = _getDiseaseColor(diseaseEn);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [

          // ── Top color bar ─────────────────
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [

                // Disease icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getDiseaseIcon(diseaseEn),
                    color: color,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                // Disease info
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        diseaseNp,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diseaseEn,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Date
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 13,
                              color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            scannedAt,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Confidence badge
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidence)
                            .withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: _getConfidenceColor(
                              confidence),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        confidence,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(
                              confidence),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}