import cv2
import numpy as np
import math

def convertAngle(angle):
    return angle * 180 / math.pi

img = cv2.imread('./imgs/edges.png', cv2.IMREAD_GRAYSCALE)

_, binary = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)

contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

mask = np.zeros_like(img)

# 假设我们只处理第一个轮廓
for cnt in contours:
    # 获取轮廓的最小外接圆
    (x, y), radius = cv2.minEnclosingCircle(cnt)
    center = (int(x), int(y))

    # 获取轮廓的角度
    angle = np.arctan2(cnt[0][0][1] - center[1], cnt[0][0][0] - center[0]) * 180 / np.pi

    # 画出完整的扇形区域
    cv2.ellipse(mask, center, (int(radius), int(radius)), 0, angle, angle + convertAngle(2 * math.asin(11.7 / 16.5)), 255, -1)

# 显示结果
cv2.imshow('Original Image', img)
cv2.imshow('Filled Fan Shape', mask)
cv2.waitKey(0)
cv2.destroyAllWindows()
