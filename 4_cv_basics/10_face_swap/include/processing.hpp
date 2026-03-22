#ifndef PROCESSING_HPP
#define PROCESSING_HPP

#include "segmentation.hpp"
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <string>

cv::Mat segmentObject(ImageSegmenter& segmenter, const cv::Mat& image, const std::string& message);

cv::Mat createMask(const cv::Mat& segmented);

int kernel_sum(const cv::Mat& source_image, int row, int col, int kernel_size);

cv::Mat erosion(cv::Mat source_image, cv::Mat output_image, int kernel_size);

cv::Mat dilation(cv::Mat source_image, cv::Mat output_image, int kernel_size);

cv::Mat smoothMask(const cv::Mat& inputMask);

void extractForeground(const cv::Mat& image, const cv::Mat& mask, cv::Mat& foreground, cv::Mat& croppedMask, cv::Rect& boundingBox);

void resizeObject(cv::Mat& object, cv::Mat& mask, const cv::Size& targetSize);

cv::Mat removeOriginalObjects(const cv::Mat& image, const cv::Mat& mask1, const cv::Mat& mask2, const cv::Rect& r1, const cv::Rect& r2);

void pasteSwappedObjects(cv::Mat& baseImage, const cv::Mat& fg1, const cv::Mat& fg2, const cv::Mat& m1, const cv::Mat& m2, const cv::Rect& r1, const cv::Rect& r2);

#endif