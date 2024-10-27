# Early test on drawing masks
import cv2
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

# Read the image
img = cv2.imread('imgs/test_screenshot.png')
# cv2.imshow('Original Image', img)
# cv2.waitKey(0)

# record its dimesnions
height, width = img.shape[:2]
print(height, width)

# create a canvas to draw the mask
mask = np.zeros((height, width), np.uint8)
# cv2.imshow('Mask', mask)
# cv2.waitKey(0)

# define the center of the fan-shaped region
center = (1030, 301 - 338)

# define the radius of the fan-shaped region
radius = 1120

# define the start and end angles of the fan-shaped region
start_angle = convertAngle(math.acos(11.7 / 16.5))  # start angle of the fan
end_angle = 90 + convertAngle(math.asin(11.7 / 16.5))  # end angle of the fan

# draw the fan-shaped region on the mask
cv2.ellipse(mask, center, (radius, radius), 0, start_angle, end_angle, 255, -1)

# I want to black out all the region above y = 66
mask[:66, :] = 0

# save and display the mask
cv2.imwrite('imgs/fan_mask.png', mask)
cv2.imshow('Fan Mask', mask)
cv2.waitKey(0)