% Clearing Workspace
clear;
clc;

% Read Image
im1 = imread("StackNinja1.bmp");
imshow(im1);
title('Input Image'); 
pause(5);

% Contrast Adjustment
im_contrast = imadjust(im1,stretchlim(im1));
imshow(im_contrast)
title('Contrast Stretching');
pause(5);

% Grab green cann
green = im_contrast(:,:,2);
imshow(green);
title('Extract Green');
pause(5);

% Clear Border
im_clear = imclearborder(green);
imshow(im_clear);
title('Clear Border');
pause(5);

% Bilateral Filter
im_bi = imbilatfilt(im_clear);
imshow(im_bi);
title('Image after Bilateral Filter');
pause(5);

% Sharpening Filter
im_sharp2 = imsharpen(im_bi);
imshow(im_sharp2);
title('Image after Sharpening');
pause(5);

% Wiener Filter
im_wiener = wiener2(im_sharp2, [5 5]);
imshow(im_wiener);
title('Image after Wiener Filter');
pause(5);

% Edge detection
im_edge = edge(im_wiener, "Canny");
imshow(im_edge);
title('Canny Edge Detection');
pause(5);

% Get rid of small holes
im_shole = bwareaopen(im_edge, 15);
imshow(im_shole);
title("Get rid of small holes");
pause(5);


% Fill Holes
SE = strel('disk', 2);
im_fill = imfill(im_shole, 'holes');
imshow(im_fill);
title("Fills Up Existing Holes");
pause(5);

% Erosion
im_erode = imerode( im_fill , SE );
imshow(im_erode);
title("Erosion to Separate");
pause(5);

% Dilation
im_dilation = imdilate(im_erode, SE);
imshow(im_dilation);
title("Dilation");
pause(5);

% Separate nuclei with Watershed
D = -bwdist(~im_dilation);   

mask = imextendedmin(D,2);

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
im_dilation(Ld2 == 0) = 0;  
imshow(im_dilation);
title("Separating Connected Objects");
pause(5);

% Count cells
CC = bwconncomp(im_dilation);
num_obj=CC.NumObjects;
disp("Number of Nuclei: " + num_obj + newline);

% Visualisation
perim_img = bwperim(im_dilation);
im_overlay = imoverlay(im1, perim_img);
imshow(im_overlay);
title("Detected Cells | Number of Cells: " + num_obj);
imwrite(im_overlay, 'final3.png');

% Calculate Area
Area = regionprops(CC, 'Area');
mean_Area = mean([Area.Area]);
sd_Area = std([Area.Area]);
disp("Average Area of Nuclei: " + mean_Area);
disp("Standard Deviation of Area of Nuclei: " + sd_Area + newline);

% Calculate Perimeter
Perimeter = regionprops(CC, 'Perimeter');
mean_Perimeter = mean([Perimeter.Perimeter]);
sd_Perimeter = std([Perimeter.Perimeter]);
disp("Average Perimeter of Nuclei: " + mean_Perimeter);
disp("Standard Deviation of Perimeter of Nuclei: " + sd_Perimeter + newline);

% Calculate Eccentricity (Closer to 0, the more round)
Eccentricity = regionprops(CC, 'Eccentricity');
mean_Eccentricity = mean([Eccentricity.Eccentricity]);
sd_Eccentricity = std([Eccentricity.Eccentricity]);
disp("Average Eccentricity of Nuclei: " + mean_Eccentricity);
disp("Standard Eccentricity of Nuclei: " + sd_Eccentricity + newline);

% Calculate Brightness
Brightness = regionprops(CC, im_wiener, 'MinIntensity');
mean_Brightness = mean([Brightness.MinIntensity]);
sd_Brightness = std(double([Brightness.MinIntensity]));
disp("Average Brightness of Nuclei: " + mean_Brightness);
disp("Standard Deviation of Brightness of Nuclei: " + sd_Brightness);