from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input  # ← ADD!
from PIL import Image
import numpy as np
import io
import sqlite3
from datetime import datetime
import hashlib

app = Flask(__name__)

def init_db():
    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS user (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        created_at TEXT
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS disease (
        disease_id INTEGER PRIMARY KEY,
        name_en TEXT,
        name_np TEXT,
        advice_np TEXT
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS scan (
        scan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        image_path TEXT,
        scanned_at TEXT,
        FOREIGN KEY (user_id) REFERENCES user(user_id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS result (
        result_id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_id INTEGER,
        disease_id INTEGER,
        confidence_score REAL,
        FOREIGN KEY (scan_id) REFERENCES scan(scan_id),
        FOREIGN KEY (disease_id) REFERENCES disease(disease_id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS feedback (
        feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_id INTEGER,
        rating INTEGER,
        comment TEXT,
        submitted_at TEXT,
        FOREIGN KEY (scan_id) REFERENCES scan(scan_id)
    )''')

    c.execute("SELECT COUNT(*) FROM disease")
    if c.fetchone()[0] == 0:
        diseases = [
            (0, 'Benign Keratosis', 'सामान्य केराटोसिस',
             '''🔍 रोग बारे:
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
- वर्षमा एकपटक छालाविज्ञ डाक्टरलाई देखाउनुहोस्'''),

            (1, 'Melanocytic Nevus', 'मेलानोसाइटिक नेभस (तिल)',
             '''🔍 रोग बारे:
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
- ABCDE rule याद राख्नुहोस्
- तिलमा परिवर्तन भएमा डाक्टर देखाउनुहोस्
- घाममा सनस्क्रिन लगाउनुहोस्
- वर्षमा एकपटक skin check गराउनुहोस्'''),

            (2, 'Melanoma', 'मेलानोमा (छाला क्यान्सर)',
             '''🔍 रोग बारे:
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
- परिवारका सदस्यलाई पनि check गराउनुहोस्'''),
        ]
        c.executemany("INSERT INTO disease VALUES (?,?,?,?)", diseases)
        print("Disease data inserted!")

    conn.commit()
    conn.close()
    print("Database ready!")

# ── Load model ────────────────────────────────────────
model = load_model(r'E:\DetectDerm\models\detectderm_3class.h5')
print("Model loaded!")
init_db()

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

# ── KEY FIX: preprocess_input use गर्नुस् ─────────────
def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes))
    img = img.convert('RGB')
    img = img.resize((224, 224))
    img_array = np.array(img, dtype=np.float32)
    img_array = preprocess_input(img_array)        # ← FIX!
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

@app.route('/')
def home():
    return jsonify({'message': 'DetectDerm API is running!'})

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data or 'name' not in data or \
       'email' not in data or 'password' not in data:
        return jsonify({'error': 'Name, email र password चाहिन्छ!'}), 400

    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()
    try:
        c.execute(
            "INSERT INTO user (name, email, password, created_at) VALUES (?,?,?,?)",
            (data['name'], data['email'],
             hash_password(data['password']),
             datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        )
        conn.commit()
        user_id = c.lastrowid
        conn.close()
        return jsonify({
            'message': 'Registration Successfully',
            'user_id': user_id,
            'name': data['name']
        })
    except sqlite3.IntegrityError:
        conn.close()
        return jsonify({'error': 'Email already registered!'}), 400

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'email' not in data or 'password' not in data:
        return jsonify({'error': 'Email र password चाहिन्छ!'}), 400

    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()
    c.execute(
        "SELECT user_id, name, email FROM user WHERE email=? AND password=?",
        (data['email'], hash_password(data['password']))
    )
    user = c.fetchone()
    conn.close()

    if user:
        return jsonify({
            'message': 'Login Successfully',
            'user_id': user[0],
            'name': user[1],
            'email': user[2]
        })
    return jsonify({'error': 'Email वा password गलत छ!'}), 401

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'Image upload गर्नुहोस्!'}), 400

    user_id = request.form.get('user_id', None)
    image_bytes = request.files['image'].read()

    # ── Image Quality Check ───────────────────────────
    pil_img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    img_array_check = np.array(pil_img)
    avg_brightness = np.mean(img_array_check)
    variance = np.var(img_array_check)

    if avg_brightness < 30:
        return jsonify({
            'error': 'not_skin',
            'message': 'Photo धेरै अँध्यारो छ!\n'
                       'राम्रो प्रकाशमा photo खिच्नुस्।'
        }), 400

    if variance < 150:
        return jsonify({
            'error': 'not_skin',
            'message': 'यो छालाको photo होइन!\n'
                       'छालाको affected area को photo खिच्नुस्।'
        }), 400

    # ── Predict ───────────────────────────────────────
    img_array = preprocess_image(image_bytes)
    predictions = model.predict(img_array)
    predicted_class = int(np.argmax(predictions[0]))
    confidence = float(np.max(predictions[0])) * 100

    if confidence < 60.0:
        return jsonify({
            'error': 'not_skin',
            'message': 'छाला रोग स्पष्ट देखिएन!\n'
                       'नजिकबाट clear photo खिच्नुस्।'
        }), 400

    # ── Save to DB ────────────────────────────────────
    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()
    c.execute(
        "INSERT INTO scan (user_id, image_path, scanned_at) VALUES (?,?,?)",
        (user_id, 'uploaded_image',
         datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    )
    scan_id = c.lastrowid
    c.execute(
        "INSERT INTO result (scan_id, disease_id, confidence_score) VALUES (?,?,?)",
        (scan_id, predicted_class, confidence)
    )
    c.execute(
        "SELECT name_en, name_np, advice_np FROM disease WHERE disease_id=?",
        (predicted_class,)
    )
    disease = c.fetchone()
    conn.commit()
    conn.close()

    return jsonify({
        'scan_id': scan_id,
        'disease_en': disease[0],
        'disease_np': disease[1],
        'advice_np': disease[2],
        'confidence': f'{confidence:.2f}%'
    })

@app.route('/feedback', methods=['POST'])
def feedback():
    data = request.get_json()
    if not data or 'scan_id' not in data or 'rating' not in data:
        return jsonify({'error': 'scan_id र rating चाहिन्छ!'}), 400

    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()
    c.execute(
        "INSERT INTO feedback (scan_id, rating, comment, submitted_at) VALUES (?,?,?,?)",
        (data['scan_id'], data['rating'],
         data.get('comment', ''),
         datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    )
    conn.commit()
    conn.close()
    return jsonify({'message': 'Feedback saved'})

@app.route('/history/<int:user_id>', methods=['GET'])
def history(user_id):
    conn = sqlite3.connect('detectderm.db')
    c = conn.cursor()
    c.execute('''
        SELECT s.scan_id, s.scanned_at, d.name_en,
               d.name_np, r.confidence_score
        FROM scan s
        JOIN result r ON s.scan_id = r.scan_id
        JOIN disease d ON r.disease_id = d.disease_id
        WHERE s.user_id = ?
        ORDER BY s.scanned_at DESC LIMIT 10
    ''', (user_id,))
    rows = c.fetchall()
    conn.close()
    return jsonify([{
        'scan_id': r[0],
        'scanned_at': r[1],
        'disease_en': r[2],
        'disease_np': r[3],
        'confidence': f'{r[4]:.2f}%'
    } for r in rows])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)