import cv2
import numpy as np

# Read the image
img = cv2.imread('imgs/screenshot1.png')

# Convert to grayscale
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Apply Gaussian blur
blurred = cv2.GaussianBlur(gray, (5, 5), 0)

# Perform Canny edge detection
edges = cv2.Canny(blurred, 50, 150)
cv2.imwrite('imgs/edges.png', edges)

# Use morphological operations to close the gaps between edge segments
kernel = np.ones((5, 5), np.uint8)
edges = cv2.dilate(edges, kernel, iterations=2)
edges = cv2.erode(edges, kernel, iterations=1)

# Find contours
contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Draw contours on a blank image
contour_img = np.zeros_like(gray)
cv2.drawContours(contour_img, contours, -1, (255, 255, 255), thickness=cv2.FILLED)

# Apply mask
mask = np.zeros_like(img)
mask[contour_img == 255] = img[contour_img == 255]

# Write the mask to a BMP file
cv2.imwrite('imgs/mask.bmp', mask)

# Display the result
cv2.imshow('Detected Fan-shaped Region', mask)
cv2.waitKey(0)
cv2.destroyAllWindows()
    
