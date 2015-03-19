//
//  ModuleBViewController.m
//  TeamBEN-A4-ObjC
//
//  Created by ch484-mac4 on 3/17/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "ModuleBViewController.h"
#import "AVFoundation/AVFoundation.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import "CvVideoCameraMod.h"
//#import "Novocaine.h"
//#import "RingBuffer.h"

#define kframesPerSecond 30
#define kBufferLength 300
#define kWindowLength 10

using namespace cv;

@interface ModuleBViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) float upBeatIntensity;
@property (nonatomic) float downBeatIntensity;
@property (nonatomic) float *avgPixelIntensityBuffer;
@property (nonatomic) int bufferIndex;
@property (nonatomic) int numBeats;

@end

@implementation ModuleBViewController

//RingBuffer *ringBuffer;

-(int)numBeats{
    if(!_numBeats) {
        _numBeats = 0;
    }
    
    return _numBeats;
}

-(int)bufferIndex {
    if(!_bufferIndex) {
        _bufferIndex = 0;
    }
    
    return _bufferIndex;
}

-(float*)avgPixelIntensityBuffer {
    if(!_avgPixelIntensityBuffer) {
        _avgPixelIntensityBuffer = (float*)calloc(kBufferLength, sizeof(float));
    }
    
    return _avgPixelIntensityBuffer;
}

-(float)upBeatIntensity {
    if(!_upBeatIntensity) {
        _upBeatIntensity = 0.0;
    }
    
    return _upBeatIntensity;
}

-(float)downBeatIntensity {
    if(!_downBeatIntensity) {
        _downBeatIntensity = 0.0;
    }
    
    return _downBeatIntensity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ringBuffer = new RingBuffer(kBufferLength, 2);
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera start];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    AVCaptureDevice *device = nil;
    
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == AVCaptureDevicePositionBack) {
            device = currentDevice;
        }
    }
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack && [device hasTorch]) {
        
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
        
    }
    
}

-(void)dealloc{
    
    free(self.avgPixelIntensityBuffer);
    
    //delete ringBuffer;
    
    //ringBuffer = nil;
    
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image{
    
    //NSLog(@"procesing");
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    Mat grayFrame, output1, output2;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    
    Scalar avgPixelIntensity = cv::mean( image_copy );
    
    char text[50];
    sprintf(text,"R: %.1f", avgPixelIntensity.val[2]);
    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
    if(avgPixelIntensity.val[0] < 57.5 && avgPixelIntensity.val[1] < 74.5) {
        AVCaptureDevice *device = nil;
        
        NSArray* allDevices = [AVCaptureDevice devices];
        for (AVCaptureDevice* currentDevice in allDevices) {
            if (currentDevice.position == AVCaptureDevicePositionBack) {
                device = currentDevice;
            }
        }
        if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack && [device hasTorch]) {
            
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOn];
            [device unlockForConfiguration];
            
            if(self.bufferIndex < kBufferLength) {
                self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
                self.bufferIndex++;
            }
            else {
                dispatch_queue_t newQueue = dispatch_queue_create("New Queue", NULL);
                
                dispatch_async(newQueue, ^{
                    float max = 0.0;
                    float tempMax = 0.0;
                    int tempMaxIndex = 0;
                    int maxIndex = 0;
                    
                    for(int i = 0; i < kBufferLength; i++){
                        
                        for(int j = 0; j < kWindowLength; j++){
                            
                            if(self.avgPixelIntensityBuffer[i+j] >= tempMax){
                                tempMax = self.avgPixelIntensityBuffer[i+j];
                                tempMaxIndex = j;
                            }
                            
                        }
                        
                        if(tempMaxIndex == (kWindowLength/2)-1){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.numBeats++;
                                   NSLog(@"%d",self.numBeats);
                                });
                        }
                        
                        tempMax = 0.0;
                        
                    }
                    
                    
                    free(self.avgPixelIntensityBuffer);
                    
                    self.avgPixelIntensityBuffer = (float*)calloc(kBufferLength,sizeof(float));
                    self.bufferIndex = 0;
                });

            }
            
        }
        
    }
    
    
    //NSLog(@"R: %.1f", avgPixelIntensity.val[2]);
    
    //float intensity = avgPixelIntensity.val[2];
        
    /*if(avgPixelIntensity.val[0] < 75.0 && avgPixelIntensity.val[1] < 75.0) {
        if(self.downBeatIntensity == 0.0 || self.upBeatIntensity == 0.0) {
            self.downBeatIntensity = intensity;
            self.upBeatIntensity = intensity;
        }
        else if(intensity >= self.downBeatIntensity && intensity >= self.upBeatIntensity) {
            self.upBeatIntensity = intensity;
        }
        else if(intensity < self.downBeatIntensity && intensity < self.upBeatIntensity) {
            self.downBeatIntensity = intensity;
        }
        else if(intensity > self.downBeatIntensity && intensity < self.upBeatIntensity) {
            NSLog(@"Heart Beat Detected!");
            self.downBeatIntensity = intensity;
            self.upBeatIntensity = intensity;
        }
    }*/
    
    //4.566667 notifications per beat
    
    //    cvtColor(image_copy, image_copy, CV_BGR2HSV); // convert to hsv
    
    //    avgPixelIntensity = cv::mean( image_copy );
    //        char text[50];
    //        sprintf(text,"Avg. H: %.1f, S: %.1f,V: %.1f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2]);
    //        cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    //    NSLog(@"Avg H: %.1f, S: %.1f, V: %.1f", avgPixelIntensity.val[0], avgPixelIntensity.val[1], avgPixelIntensity.val[2]);
    
    
    //    cvtColor(image_copy, image_copy, CV_HSV2BGR); // convert back from hsv
    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
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
//    NSLog(@"%d", self.numBeats);
}
#endif

@end
