#include "processing.hpp"
#include <opencv2/imgcodecs.hpp>
#include <iostream>
#include <stdexcept>

int main()
{
    try
    {
        cv::Mat image = cv::imread("assets/image1.png");
        if (image.empty())
            throw std::runtime_error("Could not load image");

        ImageSegmenter segmenter;

        cv::Mat segmented1 = segmentObject(segmenter, image, "Select first ROI and press any key...");
        cv::Mat segmented2 = segmentObject(segmenter, image, "Select second ROI and press any key...");

        cv::Mat mask1 = smoothMask(createMask(segmented1));
        cv::Mat mask2 = smoothMask(createMask(segmented2));

        cv::Mat fg1, fg2, m1, m2;
        cv::Rect r1, r2;

        extractForeground(image, mask1, fg1, m1, r1);
        extractForeground(image, mask2, fg2, m2, r2);

        resizeObject(fg1, m1, r2.size());
        resizeObject(fg2, m2, r1.size());

        cv::Mat swapped = removeOriginalObjects(image, mask1, mask2, r1, r2);

        pasteSwappedObjects(swapped, fg1, fg2, m1, m2, r1, r2);

        cv::imshow("Original", image);
        cv::imshow("Segmented SWAP", swapped);
        cv::waitKey(0);
        cv::destroyAllWindows();
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        return -1;
    }

    return 0;
}