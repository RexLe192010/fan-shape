# Information about fan-shape model and paper

learning fan shape model and object detection using fan shape model.

please run "train_gir.m" and "detect_gir.m" respectively.

This code has been tested on Matlab R2011b in the 64-bit windows platform.

If you have any question, please contact the author Xinggang Wang by email: wxghust@gmail.com.

Please cite the paper:
Xinggang Wang, Xiang Bai, Tianyang Ma, Wenyu Liu, Longin Latecki. Fan Shape Model for Object Detection. IEEE Computer Society Conference on Computer vision and Pattern Recognition (CVPR), 2012.


# Echocardiogram and masking

## Purpose
Generate masks for echocardiograms.

## Brute force marking
Explicitly locate the center, radius, and angle of the fan shapes.
Based on 2019-Pt3_A4C.mp4, the center is (510, 7) or (511, 7), the radius is 644, and angle is about 90 degree.

## Paths to src code
./main/generate_screenshots is a python script that generates raw frames of training video;
./main/generate_masks is a python script that generates masks for frames.

## Train and detect
I've already generated frames and masks and stored them in ./training_images/fan.