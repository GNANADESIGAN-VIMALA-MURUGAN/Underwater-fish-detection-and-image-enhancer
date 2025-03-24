clc; clear; close all;

% ======== Select Image FIRST ========
[file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select an Image File');

if isequal(file, 0) || isequal(path, 0)
    disp('User canceled the image selection. Exiting...');
    return;
end

imagePath = fullfile(path, file);
org_img = imread(imagePath);

% ======== Now Initialize GUI ========
modelPath = 'best.pt';  % YOLOv8 .pt model path

% Initialize data struct
data.org_img = org_img;
data.red_comp_img = [];
data.wb_img = [];
data.gamma_crct_img = [];
data.sharpen_img = [];
data.gray_img = [];
data.edges = [];
data.dilated_img = [];
data.filled_img = [];
data.modelPath = modelPath;
data.outputPath = '';

% Create GUI
fig = figure('Name', 'Image Processing Pipeline', 'NumberTitle', 'off', ...
    'Position', [100, 100, 1150, 700], 'MenuBar', 'none', 'ToolBar', 'none');

% Main image axes
data.ax = axes('Parent', fig, 'Units', 'pixels', 'Position', [270, 150, 860, 500]);
axis(data.ax, 'off');
title(data.ax, 'Input Image');
imshow(org_img, 'Parent', data.ax);


% Thumbnail panel
data.thumbPanel = uipanel('Parent', fig, 'Title', 'Steps', 'FontSize', 10, ...
    'Position', [0.005, 0.02, 0.23, 0.94]);
data.thumbAxes = {};

% Buttons
uicontrol('Style', 'pushbutton', 'String', 'Select Image', 'FontSize', 12, ...
    'Position', [480, 40, 120, 40], 'Callback', @(~,~) selectImage(fig));

data.nextButton = uicontrol('Style', 'pushbutton', 'String', 'Next', 'FontSize', 12, ...
    'Position', [800, 40, 100, 40], 'Callback', @(~,~) nextStep(fig), 'Enable', 'on');

data.backButton = uicontrol('Style', 'pushbutton', 'String', 'Back', 'FontSize', 12, ...
    'Position', [650, 40, 100, 40], 'Callback', @(~,~) backStep(fig), 'Enable', 'off');

% Store thumbnail for input image
data = storeThumbnail(fig, data, org_img, 'Input Image');

% Show image title correctly
imshow(org_img, 'Parent', data.ax);
title(data.ax, 'Input Image');

% Initialize step counter
data.stepCounter = 1;
guidata(fig, data);
drawnow;

% ======== Remainder of the functions (selectImage, nextStep, backStep, etc.) remain unchanged ========


%% ======== SELECT IMAGE Button Function ========
function selectImage(fig)
    data = guidata(fig);
    [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, ...
        'Select an Image File');

    if isequal(file, 0) || isequal(path, 0)
        disp('User canceled the image selection.');
        return;
    end

    imagePath = fullfile(path, file);
    data.org_img = imread(imagePath);

    % Remove the program title
    if ishandle(data.programTitle)
        delete(data.programTitle);
    end

    cla(data.ax);
    imshow(data.org_img, 'Parent', data.ax);
    title(data.ax, 'Input Image');

    % Reset thumbnails and step counter
    for i = 1:length(data.thumbAxes)
        delete(data.thumbAxes{i});
    end
    data.thumbAxes = {};

    data = storeThumbnail(fig, data, data.org_img, 'Input Image');
    data.stepCounter = 1;

    set(data.nextButton, 'Enable', 'on');
    set(data.backButton, 'Enable', 'off');
    guidata(fig, data);
    drawnow;
end

%% ======== NEXT Button Function ========
function nextStep(fig)
    data = guidata(fig);

    switch data.stepCounter
        case 1  % Red Compensation
            data.red_comp_img = redCompensate(data.org_img, 5);
            imgToShow = data.red_comp_img;
            titleText = 'Red Compensated Image';

        case 2  % White Balance
            data.wb_img = gray_balance(data.red_comp_img);
            imgToShow = data.wb_img;
            titleText = 'White Balanced Image';

        case 3  % Gamma Correction
            alpha = 1; gamma = 1.2;
            data.gamma_crct_img = gammaCorrection(data.wb_img, alpha, gamma);
            imgToShow = data.gamma_crct_img;
            titleText = 'Enhanced Image';

        case 4  % Sharpening
            data.sharpen_img = sharp(data.gamma_crct_img);
            imgToShow = data.sharpen_img;
            titleText = 'Sharpened Image';

        case 5  % Grayscale
            data.gray_img = rgb2gray(data.sharpen_img);
            imgToShow = data.gray_img;
            titleText = 'Grayscale Image';

        case 6  % Edge Detection
            data.edges = edge(data.gray_img, 'Canny');
            imgToShow = data.edges;
            titleText = 'Edge Detection';

        case 7  % Morphology
            se = strel('disk', 3);
            data.dilated_img = imdilate(data.edges, se);
            data.filled_img = imfill(data.dilated_img, 'holes');
            imgToShow = data.filled_img;
            titleText = 'Morphologically Processed Image';

        case 8  % YOLOv8 Detection on Enhanced Image
            % Generate unique filenames using timestamp
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            tempImagePath = ['temp_gamma_corrected_image_', timestamp, '.jpg'];
            uniqueOutputPath = ['output_image_', timestamp, '.jpg'];
            imwrite(data.gamma_crct_img, tempImagePath);

            try
                yolov8 = py.ultralytics.YOLO(data.modelPath);
                results = yolov8(tempImagePath);
                results{1}.save(uniqueOutputPath);
                imgToShow = imread(uniqueOutputPath);
                titleText = 'Final Result';
                disp(['Annotated image saved to: ', uniqueOutputPath]);
                data.outputPath = uniqueOutputPath;  % Save path in data
            catch ME
                error(['Failed to load YOLOv8 model or process image. Details: ', ME.message]);
            end

            delete(tempImagePath);
            set(data.nextButton, 'Enable', 'off');
            set(data.backButton, 'Enable', 'off');

        otherwise
            return;
    end

    imshow(imgToShow, 'Parent', data.ax);
    title(data.ax, titleText);
    data = storeThumbnail(fig, data, imgToShow, titleText);

    data.stepCounter = data.stepCounter + 1;
    if data.stepCounter > 1
        set(data.backButton, 'Enable', 'on');
    end
    guidata(fig, data);
    drawnow;
end

%% ======== BACK Button Function ========
function backStep(fig)
    data = guidata(fig);
    data.stepCounter = data.stepCounter - 1;

    switch data.stepCounter
        case 1
            imgToShow = data.org_img;
            titleText = 'Input Image';
        case 2
            imgToShow = data.red_comp_img;
            titleText = 'Red Compensated Image';
        case 3
            imgToShow = data.wb_img;
            titleText = 'White Balanced Image';
        case 4
            imgToShow = data.gamma_crct_img;
            titleText = 'Enhanced Image';
        case 5
            imgToShow = data.sharpen_img;
            titleText = 'Sharpened Image';
        case 6
            imgToShow = data.gray_img;
            titleText = 'Grayscale Image';
        case 7
            imgToShow = data.edges;
            titleText = 'Edge Detection';
        case 8
            imgToShow = data.filled_img;
            titleText = 'Morphologically Processed Image';
    end

    imshow(imgToShow, 'Parent', data.ax);
    title(data.ax, titleText);

    if data.stepCounter == 1
        set(data.backButton, 'Enable', 'off');
    end
    set(data.nextButton, 'Enable', 'on');
    guidata(fig, data);
    drawnow;
end

%% ======== Store Thumbnail (2 Columns) ========
function data = storeThumbnail(fig, data, img, stepTitle)
    thumbSize = [100, 100];
    thumbImg = imresize(img, thumbSize);

    idx = numel(data.thumbAxes) + 1;
    col = mod(idx-1, 2);
    row = floor((idx-1)/2);

    xPos = 10 + col * 110;
    yPos = 520 - row * 120;

    ax = axes('Parent', data.thumbPanel, 'Units', 'pixels', ...
        'Position', [xPos, yPos, 100, 100], 'XTick', [], 'YTick', []);
    hImg = imshow(thumbImg, 'Parent', ax);
    title(ax, num2str(idx), 'FontSize', 8);

    set(hImg, 'ButtonDownFcn', @(~,~) showImage(fig, img, stepTitle));
    set(ax, 'ButtonDownFcn', @(~,~) showImage(fig, img, stepTitle));

    data.thumbAxes{end+1} = ax;
end

%% ======== Show Full Image from Thumbnail ========
function showImage(fig, img, stepTitle)
    data = guidata(fig);
    imshow(img, 'Parent', data.ax);
    title(data.ax, stepTitle);
    drawnow;
end
