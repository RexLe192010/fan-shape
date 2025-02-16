import cv2
import numpy as np


def detect(img : str):
    # read the image
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 1. Gaussian blur
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # 2. Canny edge detection
    edges = cv2.Canny(blurred, 100, 120)

    # 3. Hough line detection
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=150, minLineLength=100, maxLineGap=10)

    # draw lines on the original image
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            cv2.line(img, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # # 4. Hough circle detection
    # circles = cv2.HoughCircles(edges, cv2.HOUGH_GRADIENT, dp=1.2, minDist=50,
    #                             param1=50, param2=30, minRadius=20, maxRadius=100)

    # # draw circles on the original image
    # if circles is not None:
    #     circles = np.uint16(np.around(circles))
    #     for i in circles[0, :]:
    #         cv2.circle(img, (i[0], i[1]), i[2], (0, 0, 255), 2)
    #         cv2.circle(img, (i[0], i[1]), 2, (255, 0, 0), 3)

    # show the images
    cv2.imshow('Edges', edges)
    cv2.imshow('Detected Lines & Circles', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def main():
    img2018 = cv2.imread('../../imgs/test_screenshot_2018.jpg')
    img2019 = cv2.imread('../../imgs/test_screenshot_2019.png')

    detect(img2018)
    detect(img2019)

if __name__ == '__main__':
    main()