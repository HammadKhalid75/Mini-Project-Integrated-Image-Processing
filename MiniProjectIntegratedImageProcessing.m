% Lab 6: Mini Project – Your Image Pipeline
% Goal: Combine filtering, enhancement, and feature extraction (spatial/frequency)
% to process a user-selected image.

close all; % Close all open figure windows
clear;     % Clear all variables from the workspace
clc;       % Clear the command window

% --------------------------------------------------------------------------
% 1) Load your own image
% --------------------------------------------------------------------------
% Note: Replace 'your_image.jpg' with the actual filename of your image.
% Example: 'peppers.png', 'cameraman.tif', 'my_photo.jpg'
try
    I = imread('peppers.png'); 
catch
    disp('Error: Image file not found. Please check the filename and path.');
    % As a fallback, load a standard MATLAB image
    I = imread('cameraman.tif'); 
end

% Convert to grayscale if it's a color image
if size(I, 3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

% Convert to double for processing (range [0, 1])
I_double = im2double(I_gray);

% --------------------------------------------------------------------------
% 2) Pre-process: Noise removal
% --------------------------------------------------------------------------
% Using a median filter (3x3) to remove 'salt-and-pepper' noise
% while preserving edges better than a mean filter.
I_filt = medfilt2(I_double, [3 3]);

% --------------------------------------------------------------------------
% 3) Enhance contrast
% --------------------------------------------------------------------------
% Using 'imadjust' to stretch the contrast.
% This maps intensities from [0.2, 0.8] to the full [0, 1] range,
% increasing the contrast of mid-tones.
I_enh = imadjust(I_filt, [0.2 0.8], [0 1]);

% --------------------------------------------------------------------------
% 4) Extract features (spatial domain edges)
% --------------------------------------------------------------------------
% Using the Canny edge detector to find strong structural outlines.
% [0.1 0.25] are the low and high thresholds for hysteresis.
edges = edge(I_enh, 'Canny', [0.1 0.25]);

% --------------------------------------------------------------------------
% 5) Optional frequency-domain mask (Low-Pass Filter)
% --------------------------------------------------------------------------
% Transform the enhanced image to the frequency domain
F = fftshift(fft2(I_enh));

% Get the size of the image/spectrum
[M, N] = size(F);

% Create a grid of frequency coordinates (u, v) centered at (0,0)
[u, v] = meshgrid(-N/2:N/2-1, -M/2:M/2-1);

% Create the ideal Low-Pass Filter (LPF) mask
% It's a circle of radius 60.
D = sqrt(u.^2 + v.^2); % Distance from center
Radius = 60;
H = double(D < Radius); % Mask is 1 inside the radius, 0 outside

% Apply the filter: element-wise multiplication in the frequency domain
G = F .* H;

% Transform back to the spatial domain
% 1. Inverse shift the spectrum (moves 0-freq back to corner)
% 2. Perform inverse 2D FFT
% 3. Take the real part (due to numerical precision)
I_lp = real(ifft2(ifftshift(G)));

% --------------------------------------------------------------------------
% 6) Visualization
% --------------------------------------------------------------------------
% Display all results in a single figure using 'montage'
figure;
montage({I_double, I_filt, I_enh, edges, I_lp}, 'Size', [1 5], 'ThumbnailSize', []);
title('Original | Denoised (Median) | Enhanced (Adjust) | Canny Edges | Low-Pass Result', 'FontSize', 12);