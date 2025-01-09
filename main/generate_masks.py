import cv2
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

def genMasks2019(): # generate masks for video data from 2019
    filename = '../training_images/fan/1.jpg'
    img = cv2.imread(filename)
    print(img)
    height, width = img.shape[:2]
    print(height, width)

    mask1 = np.zeros((height, width), np.uint8)
    mask2 = np.zeros((height, width), np.uint8)

    center1 = (510, 7)
    center2 = (511, 7)

    radius = 644
    start_angle = 45
    end_angle = 90 + 45

    cv2.ellipse(mask1, center1, (radius, radius), 0, start_angle, end_angle, 255, -1)
    cv2.ellipse(mask2, center2, (radius, radius), 0, start_angle, end_angle, 255, -1)

    mask1[:62, :] = 0
    mask2[:62, :] = 0

    for i in range(1, 62):
        cv2.imwrite(f'../training_images/fan/{i}.bmp', mask1)

    for i in range(62, 124):
        cv2.imwrite(f'../training_images/fan/{i}.bmp', mask2)

def genMasks2018(): # generate masks for video data from 2020
    filename = '../training_images/fan/124.jpg'
    img = cv2.imread(filename)
    height, width = img.shape[:2]
    print(height, width)

    mask = np.zeros((height, width), np.uint8)
    # cv2.imshow('Mask', mask)
    # cv2.waitKey(0)

    center = (318, 48)

    radius = 430
    start_angle = 45
    end_angle = 90 + 45

    cv2.ellipse(mask, center, (radius, radius), 0, start_angle, end_angle, 255, -1)

    mask[:51, :] = 0

    for i in range(124, 191):
        cv2.imwrite(f'../training_images/fan/{i}.bmp', mask)

    

def main():
    genMasks2019()
    genMasks2018()

if __name__ == '__main__':
    main()


# # Read the image
# img = cv2.imread('training_images/fan/screenshot0.png')
# # cv2.imshow('Original Image', img)
# # cv2.waitKey(0)

# # record its dimesnions
# height, width = img.shape[:2]
# print(height, width)

# # create a canvas to draw the mask
# mask1 = np.zeros((height, width), np.uint8)
# mask2 = np.zeros((height, width), np.uint8)
# # cv2.imshow('Mask', mask)
# # cv2.waitKey(0)

# # define the center of the fan-shaped region
# # since we can only take integer as input, we will have 2 centers
# center1 = (510, 7)
# center2 = (511, 7)

# # define the radius of the fan-shaped region
# radius = 644

# # define the start and end angles of the fan-shaped region
# start_angle = 45  # start angle of the fan
# end_angle = 90 + 45  # end angle of the fan

# # draw the fan-shaped region on the mask
# cv2.ellipse(mask1, center1, (radius, radius), 0, start_angle, end_angle, 255, -1)
# cv2.ellipse(mask2, center2, (radius, radius), 0, start_angle, end_angle, 255, -1)

# # I want to black out all the region above y = 62
# mask1[:62, :] = 0
# mask2[:62, :] = 0

# # save and display the mask
# for i in range(1, 62):
#     cv2.imwrite(f'training_images/fan/{i}.bmp', mask1)
#     # cv2.imshow(f'Fan Mask {i}', mask1)
#     # cv2.waitKey(0)

# for i in range(62, 124):
#     cv2.imwrite(f'training_images/fan/{i}.bmp', mask2)
#     # cv2.imshow(f'Fan Mask {i}', mask2)
#     # cv2.waitKey(0)