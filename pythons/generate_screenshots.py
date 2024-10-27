import cv2 as cv
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

# read the video
cap = cv.VideoCapture('2019-Pt3_A4C.mp4')

# keep track of the frame number
frame_num = 0

# read the video frame by frame
while True:
    # read the frame
    ret, frame = cap.read()
    if not ret:
        break

    # read the size of the frame
    height, width = frame.shape[:2]
    print(height, width)

    # save the frame
    cv.imwrite(f'training_images/fan/screenshot{frame_num}.png', frame)

    frame_num += 1