import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  // 🔹 Variables
  String _userName = '';
  List<dynamic> _history = [];
  bool _isLoading = true;

  // 🔹 initState
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // 🔹 API function
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          // 🔹 Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'कुल ${_history.length} scan(s)',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Loading / Empty / LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(_history[index], index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 🔹 HISTORY CARD UI (NEW)
  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final diseaseEn = item['disease_en'] ?? 'Unknown';
    final diseaseNp = item['disease_np'] ?? '';
    final confidence = item['confidence'] ?? '0%';
    final scannedAt = item['scanned_at'] ?? '';

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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.health_and_safety, color: Colors.green),
        ),
        title: Text(
          diseaseNp,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(diseaseEn),
            const SizedBox(height: 4),
            Text(
              'Confidence: $confidence',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              scannedAt,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          '#${index + 1}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // 🔹 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
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
            'पहिले scan गर्नुस्',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}