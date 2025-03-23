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

def detect(img):
    # read the image
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 1. Gaussian blur
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # 2. Canny edge detection
    edges = cv2.Canny(blurred, 100, 120)

    # for canny edge detected, use findContours to find the contours
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if contours:
        # find the biggest contour
        c = max(contours, key=cv2.contourArea)
    else:
        return
    # check if the contour is closed
    is_closed = cv2.isContourConvex(c)
    print(f'Is the contour closed? {is_closed}') # current contour is not closed

    # find the center of the contour
    M = cv2.moments(c)
    if M['m00'] != 0:
        cx = int(M['m10'] / M['m00'])
        cy = int(M['m01'] / M['m00'])
    else:
        cx, cy = 0, 0
    print(f'Center of the contour: ({cx}, {cy})')
    
    # filter the contour based on the angle between the points and the center of the contour
    filtered_contour = filter_contour_by_angle(c, cx, cy, angle_threshold=30)

    # approximate the contour
    approx = approx_contour(c)

    # find the convex hull
    hull = convex_hull(c)
    
    # generate a mask for the biggest contour
    mask1 = np.zeros_like(gray)
    mask2 = np.zeros_like(gray)
    mask3 = np.zeros_like(gray)
    cv2.fillPoly(mask1, [approx], 255)
    cv2.fillPoly(mask2, [c], 255)
    cv2.fillPoly(mask3, [filtered_contour], 255)
    # cv2.imshow('Mask', mask1)
    cv2.imshow('Contour', mask2)
    cv2.imshow('Filtered Contour', mask3)

    # 3. Hough line detection
    lines = cv2.HoughLinesP(edges, 1, np.pi / 180, threshold=150, minLineLength=100, maxLineGap=10)

    # draw lines on a mask
    mask4 = np.zeros_like(gray)
    if lines is not None:
        for line in lines:
            x1, y1, x2, y2 = line[0]
            cv2.line(mask4, (x1, y1), (x2, y2), (0, 255, 0), 2)
    cv2.imshow('Lines', mask4)

    # 4. Hough circle detection, currently not working
    # circles = cv2.HoughCircles(edges, cv2.HOUGH_GRADIENT, dp=1.2, minDist=50,
    #                             param1=50, param2=30, minRadius=200, maxRadius=600)

    # show the images
    cv2.imshow('Edges', edges)
    # cv2.imshow('Detected Lines & Circles', img)

    # # save the images
    # cv2.imwrite(f'./imgs/edges.jpg', edges)
    # cv2.imwrite(f'./imgs/detected.jpg', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def main():
    img2018 = cv2.imread('../../base images/test_screenshot_2018.jpg')
    img2019 = cv2.imread('../../base images/test_screenshot_2019.png')

    detect(img2018)
    # detect(img2019)

if __name__ == '__main__':
    main()