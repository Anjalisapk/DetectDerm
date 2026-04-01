from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import numpy as np
import io

app = Flask(__name__)

# Model load
model = load_model('models/detectderm_best_model.h5')
print(" Model loaded!")

# Classes र Nepali Advice
class_info = {
    0: {
        'name_en': 'Benign Keratosis',
        'name_np': 'सामान्य केराटोसिस',
        'advice_np': 'यो सामान्यतया हानिरहित छ। तर छालामा परिवर्तन देखिएमा छालाविज्ञ डाक्टरलाई देखाउनुहोस्।'
    },
    1: {
        'name_en': 'Actinic Keratosis',
        'name_np': 'एक्टिनिक केराटोसिस',
        'advice_np': 'यो घाम लागेर हुने छाला रोग हो। कृपया चाँडै छालाविज्ञ डाक्टरकहाँ जानुहोस्।'
    },
    2: {
        'name_en': 'Melanoma',
        'name_np': 'मेलानोमा (छाला क्यान्सर)',
        'advice_np': '⚠️ यो गम्भीर छाला रोग हो। तुरुन्तै डाक्टरकहाँ जानुहोस् र उपचार गराउनुहोस्।'
    },
    3: {
        'name_en': 'Melanocytic Nevus',
        'name_np': 'मेलानोसाइटिक नेभस (तिल)',
        'advice_np': 'यो सामान्य तिल हो। आकार वा रंग परिवर्तन भएमा डाक्टरलाई देखाउनुहोस्।'
    }
}

def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes))
    img = img.convert('RGB')
    img = img.resize((224, 224))
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    return img_array.astype(np.float32)

@app.route('/')
def home():
    return jsonify({'message': 'DetectDerm API is running!'})

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'Image upload गर्नुहोस्!'}), 400

    image_bytes = request.files['image'].read()
    img_array = preprocess_image(image_bytes)

    predictions = model.predict(img_array)
    predicted_class = int(np.argmax(predictions[0]))
    confidence = float(np.max(predictions[0])) * 100

    result = class_info[predicted_class]

    return jsonify({
        'disease_en': result['name_en'],
        'disease_np': result['name_np'],
        'advice_np': result['advice_np'],
        'confidence': f'{confidence:.2f}%'
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)