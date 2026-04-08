import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ApiService {
  // ── Flask API URL ────────────────────────
  static const String baseUrl = 'http://192.168.1.76:5000';

  // ── Disease names (Offline mode लागि) ────
  static const List<Map<String, String>> diseases = [
    {
      'name_en': 'Benign Keratosis',
      'name_np': 'सामान्य केराटोसिस',
      'advice_np': '''🔍 रोग बारे:
सामान्य केराटोसिस छालामा देखिने सामान्य वृद्धि हो जुन क्यान्सर होइन।

📌 कारणहरू:
- बुढ्यौली (उमेर बढ्दै जाँदा हुन्छ)
- लामो समय घाममा बस्दा
- आनुवंशिक कारण (परिवारमा भएमा)
- छालाको सामान्य परिवर्तन
- हर्मोनल परिवर्तन

⚠️ लक्षणहरू:
- खैरो, कालो वा पहेंलो धब्बा देखिन्छ
- छाला खस्रो र मोटो हुन्छ
- खुजली लाग्न सक्छ
- छाला उठेको जस्तो देखिन्छ
- सामान्यतया दुख्दैन

💊 सल्लाह:
- यो हानिरहित छ — घबराउनु पर्दैन
- छालामा अचानक परिवर्तन भएमा डाक्टर देखाउनुहोस्
- घाममा जाँदा सनस्क्रिन लगाउनुहोस्
- छाला सफा र moisturized राख्नुहोस्
- वर्षमा एकपटक छालाविज्ञ डाक्टरलाई देखाउनुहोस्''',
    },
    {
      'name_en': 'Actinic Keratosis',
      'name_np': 'एक्टिनिक केराटोसिस',
      'advice_np': '''🔍 रोग बारे:
एक्टिनिक केराटोसिस घामको UV किरणले गर्दा हुने छाला रोग हो।

📌 कारणहरू:
- लामो समय घाम (UV rays) मा बस्दा
- हल्का छालाका मान्छेमा बढी हुन्छ
- कमजोर immune system
- धेरै वर्षसम्म घाममा काम गर्दा
- Tanning bed को प्रयोग

⚠️ लक्षणहरू:
- खस्रो, सुख्खा धब्बा देखिन्छ
- रातो, गुलाबी वा खैरो रंगको हुन्छ
- छुँदा बालुवा जस्तो महसुस हुन्छ
- खुजली वा जलन हुन सक्छ
- कहिलेकाहीँ रगत आउन सक्छ

💊 सल्लाह:
- चाँडै छालाविज्ञ डाक्टरकहाँ जानुहोस्
- उपचार नगरेमा क्यान्सर हुन सक्छ
- घाममा जाँदा SPF 30+ सनस्क्रिन लगाउनुहोस्
- टोपी र लामो बाहुला लगाउनुहोस्
- डाक्टरले cream वा laser treatment गर्न सक्छन्''',
    },
    {
      'name_en': 'Melanoma',
      'name_np': 'मेलानोमा (छाला क्यान्सर)',
      'advice_np': '''🔍 रोग बारे:
मेलानोमा सबैभन्दा खतरनाक छाला क्यान्सर हो।

📌 कारणहरू:
- अत्यधिक UV rays exposure
- आनुवंशिक कारण (परिवारमा भएमा)
- धेरै तिल भएका मान्छेमा बढी जोखिम
- कमजोर immune system
- पहिले sunburn भएको इतिहास

⚠️ लक्षणहरू:
- तिलको आकार, रंग वा आकृति परिवर्तन
- असमान किनारा भएको धब्बा
- एकभन्दा बढी रंग भएको घाउ
- व्यास 6mm भन्दा ठूलो धब्बा
- घाउबाट रगत वा पानी आउनु

💊 सल्लाह:
- ⚠️ तुरुन्तै छालाविज्ञ डाक्टरकहाँ जानुहोस्!
- ढिलो गर्दा शरीरका अन्य भागमा फैलिन सक्छ
- आफैं घाउ काट्ने वा औषधि नलगाउनुहोस्
- नियमित check-up गराउनुहोस्
- परिवारका सदस्यलाई पनि check गराउनुहोस्''',
    },
    {
      'name_en': 'Melanocytic Nevus',
      'name_np': 'मेलानोसाइटिक नेभस (तिल)',
      'advice_np': '''🔍 रोग बारे:
मेलानोसाइटिक नेभस अर्थात् सामान्य तिल हो।

📌 कारणहरू:
- जन्मजात हुन सक्छ (Birthmark)
- घाम लाग्दा नयाँ तिल निस्कन सक्छ
- Hormonal changes (गर्भावस्था, puberty)
- आनुवंशिक कारण
- उमेरसँगै तिल बढ्न सक्छ

⚠️ लक्षणहरू:
- गोलो वा अण्डाकार आकार
- खैरो, कालो वा गुलाबी रंग
- सामान्यतया 6mm भन्दा सानो
- सपाट वा थोरै उठेको हुन्छ
- सामान्यतया दुख्दैन वा खुजली लाग्दैन

💊 सल्लाह:
- सामान्य तिल हो — धेरै चिन्ता नगर्नुहोस्
- ABCDE rule याद राख्नुहोस् (Asymmetry, Border, Color, Diameter, Evolving)
- तिलमा परिवर्तन भएमा डाक्टर देखाउनुहोस्
- घाममा सनस्क्रिन लगाउनुहोस्
- वर्षमा एकपटक skin check गराउनुहोस्''',
    },
  ];

  // ── Register new user ────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Login existing user ──────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Online predict (Flask API) ───────────
  static Future<Map<String, dynamic>> predictOnline(
      String imagePath, {int? userId}) async {
    try {
      var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/predict'),
      );
      if (userId != null) {
        request.fields['user_id'] = userId.toString();
      }
      request.files.add(
          await http.MultipartFile.fromPath('image', imagePath));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      // Online failed → trigger offline
      return {'error': 'offline'};
    }
  }

  // ── Offline predict (TFLite) ─────────────
  static Future<Map<String, dynamic>> predictOffline(
      String imagePath) async {
    try {
      // Load TFLite model from assets
      final interpreter = await Interpreter.fromAsset(
        'assets/models/detectderm_model.tflite',
      );

      // Read and preprocess image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      image = img.copyResize(image!, width: 224, height: 224);

      // Convert image to float array [1, 224, 224, 3]
      var input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = image!.getPixel(x, y);
              return [
                img.getRed(pixel) / 255.0,
                img.getGreen(pixel) / 255.0,
                img.getBlue(pixel) / 255.0,
              ];
            },
          ),
        ),
      );

      // Output array [1, 4] → 4 diseases
      var output = List.generate(1, (_) => List.filled(4, 0.0));

      // Run model
      interpreter.run(input, output);
      interpreter.close();

      // Find highest confidence class
      final scores = output[0];
      int predictedClass = 0;
      double maxScore = scores[0];
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          predictedClass = i;
        }
      }

      final confidence = (maxScore * 100).toStringAsFixed(2);
      final disease = diseases[predictedClass];

      return {
        'scan_id': 0, // No scan_id in offline mode
        'disease_en': disease['name_en'],
        'disease_np': disease['name_np'],
        'advice_np': disease['advice_np'],
        'confidence': '$confidence%',
        'is_offline': true, // Offline flag
      };
    } catch (e) {
      return {'error': 'Prediction failed: $e'};
    }
  }

  // ── Smart predict (Auto Online/Offline) ──
  static Future<Map<String, dynamic>> predict(
      String imagePath, {int? userId}) async {
    // Try online first
    final onlineResult = await predictOnline(imagePath, userId: userId);

    // If online failed → use offline TFLite
    if (onlineResult['error'] == 'offline') {
      return await predictOffline(imagePath);
    }

    return onlineResult;
  }

  // ── Save feedback ────────────────────────
  static Future<Map<String, dynamic>> saveFeedback(
      int scanId, int rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scan_id': scanId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Server connect हुन सकेन!'};
    }
  }

  // ── Get scan history ─────────────────────
  static Future<List<dynamic>> getHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$userId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }
}