import cv2
import numpy as np
from flask import Flask, request, jsonify
from keras.models import load_model
import mediapipe as mp
import base64

app = Flask(__name__)

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

model = load_model("resnet_model.h5")
labels_dict = {i: chr(65 + i) for i in range(26)}

hands = mp_hands.Hands(static_image_mode=True, min_detection_confidence=0.3, max_num_hands=2)


def get_best_hand_details(image_bytes, labels_dict):
    image_np = np.frombuffer(image_bytes, dtype=np.uint8)
    image_np = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

    H, W, _ = image_np.shape

    results = hands.process(cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB))

    highest_confidence = 0
    best_predicted_character = None
    hand_landmarks_list = []
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            if results.multi_handedness:
                handedness = results.multi_handedness[0].classification[0].label
                if handedness == "Left":
                    data_aux = []
                    for i in range(len(hand_landmarks.landmark)):
                        x = hand_landmarks.landmark[i].x
                        y = hand_landmarks.landmark[i].y
                        z = hand_landmarks.landmark[i].z  # Assuming you also have z coordinate

                        data_aux.extend([x, y, z])

                    # Reshape data_aux to match the input shape of the LSTM model
                    data_aux = np.array(data_aux).reshape((len(data_aux) // 63, 63))

                    # Make prediction
                    prediction = model.predict(data_aux)

                    # Get predicted character and confidence
                    predicted_character = np.argmax(prediction)
                    confidence = float(prediction[0][predicted_character])  # Convert to Python native float

                    if confidence > highest_confidence:
                        highest_confidence = confidence
                        best_predicted_character = labels_dict[predicted_character]

                    serialized_landmarks = []
                    for landmark in hand_landmarks.landmark:
                        serialized_landmarks.append(
                            {'x': landmark.x, 'y': landmark.y, 'z': landmark.z if hasattr(landmark, 'z') else None})
                    hand_landmarks_list.append(serialized_landmarks)

    return best_predicted_character, highest_confidence, hand_landmarks_list


percentage_mapping = {
    'A': 30,
    'B': 99,
    'C': 99,
    'D': 95,
    'E': 75,
    'F': 97,
    'G': 40,
    'H': 55,
    'I': 55,
    'J': 94,
    'K': 70,
    'L': 95,
    'M': 60,
    'N': 55,
    'O': 50,
    'P': 85,
    'Q': 75,
    'R': 56,
    'S': 80,
    'T': 93,
    'U': 70,
    'V': 85,
    'W': 80,
    'X': 75,
    'Y': 95,
    'Z': 99,
}


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json.get('data')
    # Decode the base64 string to obtain the image bytes
    image_bytes = base64.b64decode(data)
    prediction, confidence, hand_landmarks_list = get_best_hand_details(image_bytes, labels_dict)
    percentage = percentage_mapping.get(prediction, 0)

    if confidence < percentage / 100:
        prediction = ""
        confidence = 0

    return jsonify({
        'prediction': prediction,
        'confidence': confidence,
        'hand_landmarks': hand_landmarks_list
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)