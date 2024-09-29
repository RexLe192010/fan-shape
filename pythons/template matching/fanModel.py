import cv2
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

# create a blank image with larger size
image_size = (1200, 1200)  # Size of the canvas
image = np.zeros((image_size[0], image_size[1], 3), dtype=np.uint8)

# define the parameters for the fan-shaped region
center = (image_size[1] // 2, image_size[0] // 4)  # center of the fan
radius = 700  # radius of the fan
start_angle = convertAngle(math.acos(11.7 / 16.5))  # start angle of the fan
end_angle = 90 + convertAngle(math.asin(11.7 / 16.5))  # end angle of the fan
color = (255, 255, 255)  # color of the fan
thickness = -1  # thickness of the fan

# draw the fan-shaped region on the image
cv2.ellipse(image, center, (radius, radius), 0, start_angle, end_angle, color, thickness)

# write to an image
cv2.imwrite('imgs/fan.bmp', image)

# display the image
cv2.imshow('Standard Fan', image)
cv2.waitKey(0)
cv2.destroyAllWindows()

