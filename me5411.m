% Clear the workspace and console
clc;
clear;

% Read the image
img = imread('C:\Users\77248\Downloads\5411\charact2.bmp');

% Convert the image to grayscale if it's not already
if size(img, 3) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img; % If the image is already grayscale
end

% Define and apply the averaging filter
averageFilter = ones(3) / 9; % Define a 3x3 averaging filter
smoothedImage = conv2(double(imgGray), averageFilter, 'same'); % Apply the averaging filter

% Define the initial "rotating" filter and apply rotations
initialFilter = [8 1 1; 1 1 1; 1 1 1];
initialFilter = initialFilter / sum(initialFilter(:)); % Normalize the filter
rotatedImage = smoothedImage; % Initialize with smoothed image

for i = 1:4 % Apply 4 rotations
    rotatedImage = conv2(double(rotatedImage), initialFilter, 'same'); % Apply current filter
    initialFilter = rot90(initialFilter); % Rotate filter by 90 degrees for the next iteration
end

% Process the image to extract "HD44780A00", find outlines and segment characters
thresholdValue = graythresh(imgGray); % Automatic threshold selection using Otsu method
imgBw = imbinarize(imgGray, thresholdValue); 
imgBw = imopen(imgBw, strel('disk', 2)); % Morphological opening
imgBw = bwareaopen(imgBw, 100); % Remove small objects
seErode = strel('line', 3, 90); % Erode to highlight vertical features
imgEroded = imerode(imgBw, seErode);

% Inflate again to restore original character dimensions
seDilate = strel('line', 5, 90);
imgDilated = imdilate(imgEroded, seDilate);
lower = imgEroded(211:334, :); % Extract sub-image

% Find edges and segment characters
charEdges = edge(lower, 'canny'); % Detect edges
[charLabels, ~] = bwlabel(lower); % Label connected components
coloredLabels = label2rgb(charLabels, 'hsv', 'k', 'shuffle'); % Color labels for visualization

% Display Original, Smoothed, and Rotated Filtered Images in one figure
figure('Name', 'Image Processing Steps', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);
subplot(1, 3, 1); % First subplot for the original image
imshow(img);
title('Original Image');

subplot(1, 3, 2); % Second subplot for the image after smoothing
imshow(uint8(smoothedImage));
title('After Averaging Filter');

% Apply the rotating filter using the previously defined 'initialFilter'
rotatedImage = smoothedImage; % Initialize with the smoothed image
for i = 1:4 % Apply 4 rotations
    rotatedImage = conv2(double(rotatedImage), initialFilter, 'same'); % Apply current filter
    initialFilter = rot90(initialFilter); % Rotate filter by 90 degrees for the next iteration
end

subplot(1, 3, 3); % Third subplot for the image after rotating mask
imshow(uint8(rotatedImage));
title('After Rotating Filter');

% Display the sub-image, edges, and labeled characters
figure('Name', 'Sub-image and Analysis', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 400]);
subplot(1, 3, 1);
imshow(lower);
title('HD44780A00 Sub-image');

subplot(1, 3, 2);
imshow(charEdges);
title('Character Outlines');

subplot(1, 3, 3);
imshow(coloredLabels);
title('Segmented and Labeled Characters');

% Calculate and display the horizontal projection
H = sum(lower, 2); % Horizontal sum, use 'lower' to sum only the relevant part
figure('Name', 'Horizontal Projection', 'NumberTitle', 'off');
plot(H);
title('Horizontal Projection');


