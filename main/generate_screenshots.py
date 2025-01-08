import cv2 as cv
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

def genScreenshot(frame_num, filename): # the filename is the path to the video
    cap = cv.VideoCapture(filename)
    print(filename)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        height, width = frame.shape[:2]
        print(height, width)

        cv.imwrite(f'../training_images/fan/{frame_num}.jpg', frame)

        frame_num += 1
    
    # output the number of frames for further screenshots generation
    return frame_num

def main():
    current_frame = genScreenshot(frame_num=1, filename='../2019-Pt3_A4C.mp4')
    print("2019 done")
    new_frame = genScreenshot(frame_num=current_frame, filename='../2018-Pt269_A4C.mp4')
    print("2018 done")


if __name__ == '__main__':
    main()



# # read the video
# cap = cv.VideoCapture('2019-Pt3_A4C.mp4')

# # keep track of the frame number
# frame_num = 1

# # read the video frame by frame
# while True:
#     # read the frame
#     ret, frame = cap.read()
#     if not ret:
#         break

#     # read the size of the frame
#     height, width = frame.shape[:2]
#     print(height, width)

#     # save the frame
#     cv.imwrite(f'training_images/fan/{frame_num}.jpg', frame)

#     frame_num += 1