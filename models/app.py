from flask import Flask, request, jsonify
import os
import cv2
import numpy as np
from werkzeug.utils import secure_filename

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/detect_shapes', methods=['POST'])
def detect_shapes():
    # Check if a file was uploaded
    if 'file' not in request.files:
        print('No file part')
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    
    # Check if the file is allowed
    if file.filename == '':
        print('No selected file')
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        # Convert base64 string to image
        print('Converting base64 string to image')
        img_str = file.read()
        nparr = np.frombuffer(img_str, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Process the image
        print('Processing image')
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        _, thresh = cv2.threshold(gray, 240, 255, cv2.THRESH_BINARY)
        
        contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        print(f"Number of contours: {len(contours)}")
        
        shapes = []
        
        for contour in contours:
            approx = cv2.approxPolyDP(contour, 0.04 * cv2.arcLength(contour, True), True)
            print(f"Number of vertices: {len(approx)}")
            num_vertices = len(approx)
            
            shape_name = ""
            if num_vertices == 3:
                shape_name = "Triangle"
            elif num_vertices == 4:
                if cv2.isContourConvex(approx):
                    shape_name = "Rectangle"
                else:
                    shape_name = "Quadrilateral"
            elif num_vertices >= 5:
                shape_name = f"P{num_vertices}-gon"
            else:
                shape_name = "Circle"
            print(f"Shape: {shape_name}")
            
            # Calculate angles for the shape
            # angles = calculate_angles(approx)
            
            shape_data = {
                'shape': shape_name,
                # 'angles': angles
            }
            
            shapes.append(shape_data)
        
        print(shapes)
        return jsonify(shapes)
    else:
        print('File type not supported')
        return jsonify({'error': 'File type not supported'}), 400

def calculate_angles(approx):
    angles = []
    for i in range(len(approx)):
        p1 = approx[i]
        p2 = approx[(i + 1) % len(approx)]
        p3 = approx[(i + 2) % len(approx)]
        
        v1 = np.array(p2) - np.array(p1)
        v2 = np.array(p3) - np.array(p2)
        
        dot_product = np.dot(v1, v2)
        magnitude_v1 = np.linalg.norm(v1)
        magnitude_v2 = np.linalg.norm(v2)
        
        cos_angle = dot_product / (magnitude_v1 * magnitude_v2)
        angle = np.arccos(cos_angle)
        
        # Convert radians to degrees
        angle_degrees = np.degrees(angle)
        
        # Handle angles greater than 180°
        if angle_degrees > 180:
            angle_degrees -= 360
        
        angles.append(angle_degrees)
    print(angles)
    return angles

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
