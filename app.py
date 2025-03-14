from ultralytics import YOLO
import cv2
import os

# Path to the trained YOLOv8 model (.pt file)
MODEL_PATH = "best.pt"  # Replace with your model path

# Path to the user-provided image
IMAGE_PATH = "image copy 3.png"  # Replace with your image path

# Load the YOLOv8 model
model = YOLO(MODEL_PATH)

# Function to perform inference on the user-provided image
def test_yolov8_model(image_path):
    # Check if the image exists
    if not os.path.exists(image_path):
        print(f"Error: The image file '{image_path}' does not exist.")
        return

    # Perform inference on the image
    results = model(image_path)

    # Visualize the results on the image
    for result in results:
        # Plot the annotated image
        annotated_image = result.plot()

        # Display the annotated image using OpenCV
        cv2.imshow("YOLOv8 Inference", annotated_image)
        cv2.waitKey(0)  # Wait for a key press to close the window
        cv2.destroyAllWindows()

        # Optionally, save the annotated image
        output_path = "output_image.jpg"
        cv2.imwrite(output_path, annotated_image)
        print(f"Annotated image saved to: {output_path}")

# Run the inference function
if __name__ == "__main__":
    test_yolov8_model(IMAGE_PATH)