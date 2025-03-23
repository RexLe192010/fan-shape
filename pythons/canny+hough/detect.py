import cv2
import numpy as np


def filter_contour_by_angle(contour, xc, yc, angle_threshold=30):
    """ Filter contour points based on the angle between the points and the center of the contour."""
    filtered_contour = []
    prev_angle = None

    for point in contour:
        x, y = point[0]
        angle = np.arctan2(y - yc, x - xc)  # compute the angle between the point and the center of the contour
        angle = np.degrees(angle)  # convert the angle to degrees

        if prev_angle is not None:
            delta_angle = abs(angle - prev_angle)
            if delta_angle > angle_threshold:  # if the angle is greater than the threshold, skip the point
                continue

        filtered_contour.append([x, y])
        prev_angle = angle

    return np.array(filtered_contour).reshape((-1, 1, 2))

def approx_contour(contour):
    """ Approximate the contour using cv2.approxPolyDP."""
    epsilon = 0.01 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    return approx

def convex_hull(contour):
    """ Find the convex hull of the contour using cv2.convexHull."""
    hull = cv2.convexHull(contour)
    return hull


def hough_line_detection(img):
    mask = np.zeros_like(img)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    lines = cv2.HoughLines(edges, 1, np.pi / 180, threshold=100)
    if lines is not None:
        for line in lines:
            rho, theta = line[0]
            a = np.cos(theta)
            b = np.sin(theta)
            x0 = a * rho
            y0 = b * rho
            x1 = int(x0 + 1000 * (-b))
            y1 = int(y0 + 1000 * (a))
            x2 = int(x0 - 1000 * (-b))
            y2 = int(y0 - 1000 * (a))
            cv2.line(mask, (x1, y1), (x2, y2), (0, 0, 255), 2)
    cv2.imshow('Hough Lines', mask)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def hough_circle_detection(img):
    mask = np.zeros_like(img)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150, apertureSize=3)
    circles = cv2.HoughCircles(edges, cv2.HOUGH_GRADIENT, dp=1.2, minDist=50,
                               param1=50, param2=30, minRadius=200, maxRadius=600)
    if circles is not None:
        circles = np.uint16(np.around(circles))
        for circle in circles[0, :]:
            center = (circle[0], circle[1])
            radius = circle[2]
            cv2.circle(mask, center, radius, (0, 255, 0), 2)
    cv2.imshow('Hough Circles', mask)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def is_contour_closed(contour):
    """ Check if the contour is closed by checking if the start is the same as the end."""
    return np.array_equal(contour[0], contour[-1])

def detect(img):
    # read the image
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 1. Gaussian blur
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # 2. Canny edge detection
    edges = cv2.Canny(blurred, 100, 120)

    # 3. dilate the edges
    kernel = np.ones((2, 2), np.uint8)
    dilated = cv2.dilate(edges, kernel, iterations=1)

    # for canny edge detected, use findContours to find the contours
    contours_normal, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if contours_normal:
        # find the biggest contour
        c_normal = max(contours_normal, key=cv2.contourArea)
    else:
        return
    
    contours_dilated, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if contours_dilated:
        # find the biggest contour
        c_dilated = max(contours_dilated, key=cv2.contourArea)
    else:
        return
    
    # check if the contours are closed
    is_closed_normal = is_contour_closed(c_normal)
    is_closed_dilated = is_contour_closed(c_dilated)
    print(f'Normal Contour is closed: {is_closed_normal}')
    print(f'Dilated Contour is closed: {is_closed_dilated}')
    
    # generate a mask for the biggest contour
    mask = np.zeros_like(gray)
    mask2 = np.zeros_like(gray)
    cv2.fillPoly(mask, [c_normal], 255)
    cv2.fillPoly(mask2, [c_dilated], 255)
    cv2.imshow('Normal Contour', mask)
    cv2.imshow('Dilated Contour', mask2)

    # # 3. Hough line and circle detection
    # hough_line_detection(img)
    # hough_circle_detection(img)


    # show the edges detected
    cv2.imshow('Edges', edges)

    # # save the images
    # cv2.imwrite(f'./imgs/edges.jpg', edges)
    # cv2.imwrite(f'./imgs/detected.jpg', img)
    cv2.imwrite(f'./imgs/contour_normal.jpg', mask)
    cv2.imwrite(f'./imgs/contour_dilated.jpg', mask2)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def main():
    img2018 = cv2.imread('../../base images/test_screenshot_2018.jpg')
    img2019 = cv2.imread('../../base images/test_screenshot_2019.png')

    detect(img2018)
    # detect(img2019)

if __name__ == '__main__':
    main()