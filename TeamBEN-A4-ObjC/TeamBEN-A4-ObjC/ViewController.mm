//
//  ViewController.m
//  SMUOpenCV
//
//  Created by Eric Larson on 2/27/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
using namespace cv;

@interface ViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) BOOL torchIsOn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    //    self.torchIsOn = !self.torchIsOn;
    //    [self setTorchOn:self.torchIsOn];
    
    [self.videoCamera start];
    
    //    self.torchIsOn = NO;
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    
    NSLog(@"procesing");
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output;
    
    //============================================
    // color inverter
    //    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    //
    //    // invert image
    //    bitwise_not(image_copy, image_copy);
    //    // copy back for further processing
    //    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
    //============================================
    //access pixels
    //    static uint counter = 0;
    //    cvtColor(image, image_copy, CV_BGRA2BGR);
    //    for(int i=0;i<counter;i++){
    //        for(int j=0;j<counter;j++){
    //            uchar *pt = image_copy.ptr(i, j);
    //            pt[0] = 255;
    //            pt[1] = 0;
    //            pt[2] = 255;
    //
    //            pt[3] = 255;
    //            pt[4] = 0;
    //            pt[5] = 0;
    //        }
    //    }
    //    cvtColor(image_copy, image, CV_BGR2BGRA);
    //
    //    counter++;
    //    counter = counter>200 ? 0 : counter;
    
    //============================================
    // get average pixel intensity
    //    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    //    Scalar avgPixelIntensity = cv::mean( image_copy );
    //    char text[50];
    //    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    //    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
    //============================================
    // change the hue inside an image
    
    //convert to HSV
    //    cvtColor(image, image_copy, CV_BGRA2BGR);
    //    cvtColor(image_copy, image_copy, CV_BGR2HSV);
    //
    //    //grab  just the Hue chanel
    //    vector<Mat> layers;
    //    cv::split(image_copy,layers);
    //
    //    // shift the colors
    //    cv::add(layers[0],80.0,layers[0]);
    //
    //    // get back image from separated layers
    //    cv::merge(layers,image_copy);
    //
    //    cvtColor(image_copy, image_copy, CV_HSV2BGR);
    //    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif

- (IBAction)toggleTorch:(id)sender {
    // you will need to fix the problem of video stopping when the torch is applied in this method
    
    self.torchIsOn = !self.torchIsOn;
    [self setTorchOn:self.torchIsOn];
    
}

- (void)setTorchOn: (BOOL) onOff
{
    AVCaptureDevice *device = nil;
    
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == AVCaptureDevicePositionBack) {
            device = currentDevice;
        }
    }
    
    
    //    AVCaptureDevice *device = [AVCaptureDevice
    //                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        
        [device lockForConfiguration:nil];
        [device setTorchMode: onOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
    }
    
}


@end
