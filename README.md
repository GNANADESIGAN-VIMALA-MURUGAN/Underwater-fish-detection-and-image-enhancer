# Underwater Image Enhancer and Object Detection

This project focuses on enhancing underwater images using various image processing techniques and performing object detection on the enhanced images using a pre-trained YOLO model.

## Features

- **Image Enhancement**: Utilizes MATLAB scripts for gamma correction, Gaussian pyramid, gray balance, red compensation, and sharpening to improve underwater image quality.
- **Object Detection**: Employs YOLO (You Only Look Once) for detecting objects in underwater environments, trained on an aquarium dataset.
- **Dataset**: Includes a pre-trained dataset for object detection in aquarium settings.

## Requirements

- **Python**: 3.10
- **MATLAB**: R2024b (with Image Processing Toolbox)
- **Python Libraries**:
  - PyTorch (for YOLO model inference)
  - OpenCV (for image processing)
  - NumPy
  - Ultralytics (for YOLOv8)
- **Hardware**: GPU recommended for faster inference (optional)

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/underwater-image-enhancer-object-detection.git
   cd underwater-image-enhancer-object-detection
   ```

2. **Install Python Dependencies**:
   ```bash
   pip install torch torchvision opencv-python numpy ultralytics
   ```

3. **MATLAB Setup**:
   - Ensure MATLAB R2024b is installed.
   - Add the project directory to MATLAB path or run scripts from the directory.

## Usage

### Image Enhancement (MATLAB)

Run the MATLAB scripts in sequence for image enhancement:

1. Load your underwater image.
2. Apply enhancements:
   - `gammaCorrection.m`: Adjusts gamma for better contrast.
   - `gaussian_pyramid.m`: Applies Gaussian pyramid for multi-scale processing.
   - `gray_balance.m`: Balances gray levels.
   - `redCompensate.m`: Compensates for red channel attenuation in water.
   - `sharp.m`: Sharpens the image.
   - `NEW.m`: Additional custom enhancements.

Example MATLAB code:
```matlab
% Load image
img = imread('input_image.jpg');

% Apply enhancements
img = gammaCorrection(img);
img = gaussian_pyramid(img);
% ... apply other functions

% Save enhanced image
imwrite(img, 'enhanced_image.jpg');
```

### Object Detection (Python)

Use the pre-trained YOLO model for object detection on enhanced images.

1. Ensure `best.pt` is in the project directory.
2. Run the detection script (assuming `app.py` is the main script):

   ```bash
   python app.py --image enhanced_image.jpg
   ```

   (Note: Adjust the script name if different. The project includes `app.py` for Python-based operations.)

The script will output detected objects with bounding boxes.

### Dataset

The `aquarium_pretrain_dataset/` contains training, validation, and test sets for object detection. It includes images and corresponding YOLO-format labels.

- **data.yaml**: Configuration file for the dataset.
- **train/**: Training images and labels.
- **test/**: Test images and labels.

## Model

- `best.pt`: Pre-trained YOLOv8 model weights for object detection in underwater/aquarium environments.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Dataset sourced from Roboflow Aquarium Dataset.
- YOLO implementation based on Ultralytics YOLOv8.
