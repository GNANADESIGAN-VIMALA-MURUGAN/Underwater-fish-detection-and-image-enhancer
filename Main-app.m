clc; clear; close all;

% Paths
modelPath = 'best.pt';  % Replace with the path to your YOLOv8 .pt model
outputPath = 'output_image.jpg'; % Path to save the annotated image

% Allow the user to select an image file interactively
[file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, ...
    'Select an Image File');

% Check if the user canceled the selection
if isequal(file, 0) || isequal(path, 0)
    disp('User canceled the image selection. Exiting...');
    return;
end

% Construct the full file path
imagePath = fullfile(path, file);

% Read the selected input image
data.org_img = imread(imagePath);

% Initialize variables for processing steps
data.red_comp_img = [];
data.wb_img = [];
data.gamma_crct_img = [];
data.sharpen_img = [];
data.gray_img = [];
data.edges = [];
data.dilated_img = [];
data.filled_img = [];
data.modelPath = modelPath;
data.outputPath = outputPath;

% Create a figure window for displaying images and buttons
fig = figure('Name', 'Image Processing Pipeline', 'NumberTitle', 'off', ...
    'Position', [100, 100, 800, 600], 'MenuBar', 'none', 'ToolBar', 'none');
axis off;

% Create an axes inside the figure for displaying images
data.ax = axes('Parent', fig, 'Position', [0.1, 0.2, 0.8, 0.7]);
axis(data.ax, 'off');

% Initialize the step counter
data.stepCounter = 1;

% Create a Next button
data.nextButton = uicontrol('Style', 'pushbutton', 'String', 'Next', ...
    'Position', [300, 10, 200, 40], 'Callback', @(src, event) nextStep(fig));

% Store data using guidata
guidata(fig, data);

% Display the initial input image
imshow(data.org_img, 'Parent', data.ax);
title(data.ax, 'Input Image');
drawnow;

% Function to handle the "Next" button click
function nextStep(fig)
    data = guidata(fig);
    
    switch data.stepCounter
        case 1
            data.red_comp_img = redCompensate(data.org_img, 5);
            imshow(data.red_comp_img, 'Parent', data.ax);
            title(data.ax, 'Red Compensated Image');
        
        case 2
            data.wb_img = gray_balance(data.red_comp_img);
            imshow(data.wb_img, 'Parent', data.ax);
            title(data.ax, 'White Balanced Image');
        
        case 3
            alpha = 1;
            gamma = 1.2;
            data.gamma_crct_img = gammaCorrection(data.wb_img, alpha, gamma);
            imshow(data.gamma_crct_img, 'Parent', data.ax);
            title(data.ax, 'Gamma Corrected Image');
        
        case 4
            data.sharpen_img = sharp(data.gamma_crct_img);
            imshow(data.sharpen_img, 'Parent', data.ax);
            title(data.ax, 'Sharpened Image');
        
        case 5
            data.gray_img = rgb2gray(data.sharpen_img);
            imshow(data.gray_img, 'Parent', data.ax);
            title(data.ax, 'Grayscale Image');
        
        case 6
            data.edges = edge(data.gray_img, 'Canny');
            imshow(data.edges, 'Parent', data.ax);
            title(data.ax, 'Edge Detection');
        
        case 7
            se = strel('disk', 3);
            data.dilated_img = imdilate(data.edges, se);
            data.filled_img = imfill(data.dilated_img, 'holes');
            imshow(data.filled_img, 'Parent', data.ax);
            title(data.ax, 'Morphologically Processed Image');
        
        case 8
            tempImagePath = 'temp_gamma_corrected_image.jpg';
            imwrite(data.gamma_crct_img, tempImagePath);

            try
                yolov8 = py.ultralytics.YOLO(data.modelPath);
                results = yolov8(tempImagePath);
            catch
                error('Failed to load YOLOv8 model. Ensure the Python environment is configured.');
            end

            for i = 1:length(results)
                annotatedImage = results{i}.plot();
                annotatedImageMatlab = uint8(annotatedImage);
                imshow(annotatedImageMatlab, 'Parent', data.ax);
                title(data.ax, 'Final Result');
                imwrite(annotatedImageMatlab, data.outputPath);
                disp(['Annotated image saved to: ', data.outputPath]);
            end

            delete(tempImagePath);
            set(data.nextButton, 'Enable', 'off');
            disp('Processing complete.');
    end

    data.stepCounter = data.stepCounter + 1;
    guidata(fig, data);
    drawnow;
end
