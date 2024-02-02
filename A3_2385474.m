clear all; clc;


segmentedImage=segmentation("Oranges.tif"); 
[biggerHalfCut,smallerHalfCut]=counting(segmentedImage);


function segmentedOutput = segmentation(originalImage)

% Read the image 
    I=imread(originalImage);
    %store temporary original image for displaying it in the first subplot
    originalImageTemp=I;
    %convert the original image to grayscale
    I=rgb2gray(I);

% Plot the histogram of an image I to see what should be threshold values
  % imhist(f);

% I Applied bi-level thresholding and create new image sb.
% I used 240 as a threshold value because it is clearly seen that we can
% divide the histogram into two region by choosing a pixel value as 240.
    sb=I;
    sb(sb<=240)=0;
    sb(sb>240)=255;

    BI=im2double(sb);%converting image to binary image
    BIComplement=1-BI;%taking the complement of the binary image to be able to fill the holes
    SegmentedImg=imfill(BIComplement,"holes");%filling the holes using imfill build-in func.
    
    se = strel('disk',1);%here, I Morphologically open image.
    SegmentedImg = imopen(SegmentedImg,se);
    
    %Plot the results
    figure; 
    subplot(1,4,1); imshow(originalImageTemp);title('Step1- Original Image');
    subplot(1,4,2); imshow(sb);title('Step2- Bi-level Thresholded Image');
    subplot(1,4,3); imshow(BIComplement);title('Step3- Complement of Thresholded Image');
    subplot(1,4,4); imshow(SegmentedImg);title('Step4- Filled(Segmented) Image');
    
    segmentedOutput=SegmentedImg;

end
function [biggerHalfCut,smallerHalfCut] = counting(segmentedImage)

% Find the number of connected components in the segmented image  using
% bwconncomp built-in function (C will be a structure)
% When I found C, the number of total components will be stored in C 
% as "numComponents" 
% My plan to count the half oranges is  as follows:
% Use connected-component Extraction to eliminate the smaller half cuts first.
% The remaining half cuts of my image is only the bigger ones,then count them using
% bwlabel built in function.After that, I will use exacly same method to eliminate the
% bigger half cuts.


    C =  bwconncomp(segmentedImage);
    
% Get the value of connected components
    numComponents = size(C.PixelIdxList,2);

% Get the number of pixels in each connected component  
    numPixels = cellfun(@numel,C.PixelIdxList);

% Get the biggest and smallest number of pixels of the connected components
%In "oranges.tif", the largest value of bigger half cut oranges are same,
%but in other test pictures,the biggest value of bigger half cut oranges
%are not same, so I take the average of the biggest and smallest value, and
%do my erase calculations based on this average value. This is because I
%know that small half cut oranges are 100% percent smaller than this
%average pixel value.

    biggestPixel = max(numPixels);
    smallestPixel=min(numPixels);
    average=(biggestPixel+smallestPixel)/2;

    %I created two temporary Image. One of them is to remove the smaller
    %half cut oranges, and the other one is to remove the bigger half cut
    %oranges.
    tempDeleteSmallerHalfCut=segmentedImage;
    tempDeleteBiggerHalfCut=segmentedImage;

    %this for loop deletes(set the pixel value as 0) the smaller half cut
    %oranges.
    for j=1: numComponents
         if (numPixels(j)<average )
              tempDeleteSmallerHalfCut(C.PixelIdxList{j})=0;
         end
    end

 %finding the bigger half cut oranges using bwlabel built-in func 
 [labeledImage1, numberOfBiggerCircles] = bwlabel(tempDeleteSmallerHalfCut);


    %this for loop deletes(set the pixel value as 0) the bigger half cut
    %oranges.
    for j=1: numComponents
         if (numPixels(j)>average )
              tempDeleteBiggerHalfCut(C.PixelIdxList{j})=0;
         end
    end
 
% Find the  number of smaller half cut oranges using bwlabel built-in func
 [labeledImage2, numberOfSmallerCircles] = bwlabel(tempDeleteBiggerHalfCut);




figure;
subplot(1,3,1);imshow(segmentedImage);title('segmented Image');
subplot(1,3,2);imshow(tempDeleteSmallerHalfCut);title("big half-cut oranges:" + numberOfBiggerCircles );
subplot(1,3,3);imshow(tempDeleteBiggerHalfCut);title("small half-cut oranges:" + numberOfSmallerCircles );
biggerHalfCut=numberOfBiggerCircles;
smallerHalfCut=numberOfSmallerCircles;

end