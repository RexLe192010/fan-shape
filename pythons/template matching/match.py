import cv2
import numpy as np
import math

# read the fan-shaped region template
fan_template = cv2.imread('./imgs/fan.bmp', cv2.IMREAD_GRAYSCALE)

# read the image
img = cv2.imread('./imgs/edges.png')
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# resize the template to match the size of the image
# calculate the scaling factor to maintain the aspect ratio
scale_factor = min(img_gray.shape[1] / fan_template.shape[1], img_gray.shape[0] / fan_template.shape[0])

# calculate the new dimensions
new_width = int(fan_template.shape[1] * scale_factor)
new_height = int(fan_template.shape[0] * scale_factor)

# resize the template
fan_template = cv2.resize(fan_template, (new_width, new_height))
cv2.imshow('Fan Template', fan_template)

# perform template matching
result = cv2.matchTemplate(img_gray, fan_template, cv2.TM_CCOEFF_NORMED)

# set a threshold to filter out weak matches
threshold = 0.7 
y_loc, x_loc = np.where(result >= threshold)

# create a mask to highlight the matched region
mask = np.zeros_like(img_gray)

# draw rectangles around the matched regions
for pt in zip(x_loc, y_loc):
    cv2.rectangle(mask, pt, (pt[0] + fan_template.shape[1], pt[1] + fan_template.shape[0]), 255, -1)

# apply the mask to the original image
masked_image = cv2.bitwise_and(img, img, mask=mask)

# display the result
cv2.imshow('Detected Fan Shape', img)
cv2.imshow('Mask', mask)
cv2.imshow('Masked Image', masked_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
