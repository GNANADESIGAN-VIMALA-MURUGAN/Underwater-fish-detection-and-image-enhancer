modelName = 'tinyYOLOv2-coco';
helper.downloadPretrainedYOLOv2(modelName);

pretrained = load(modelName);
detector = pretrained.yolov2Detector;

 wcam = webcam(1);img=snapshot(wcam);

% img = imread('1.jpg');
[boxes, scores, labels] = detect(detector, img);

% Visualize detection results.
img = insertObjectAnnotation(img,'rectangle',boxes,labels);
str = string(labels);C = char(str);
% tts(C);
 imshow(img)
% end
