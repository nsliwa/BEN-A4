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

#define kBufferLength 6000
#define kWindowLength 15

using namespace cv;

@interface ModuleBViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSTimer *timer;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) float upBeatIntensity;
@property (nonatomic) float downBeatIntensity;
@property (nonatomic) float *avgPixelIntensityBuffer;
@property (nonatomic) int bufferIndex;
@property (nonatomic) int numBeats;
@property (nonatomic) bool stopProcessing;
@property (nonatomic) bool readingSamples;
@property (nonatomic) bool initializedHR;

@end

@implementation ModuleBViewController

//NSTimer *t;

-(bool)initializedHR {
    if(!_initializedHR) {
        _initializedHR = false;
    }
    
    return _initializedHR;
}

-(bool)readingSamples {
    if(!_readingSamples) {
        _readingSamples = false;
    }
    
    return _readingSamples;
}

-(bool)stopProcessing {
    if(!_stopProcessing) {
        _stopProcessing = false;
    }
    
    return _stopProcessing;
}

-(int)numBeats {
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.videoCamera start];
    
    //self.statusLabel.text = @"Place finger on camera lense";
    NSLog(@"Place finger on camera lense");
    self.statusLabel.text = @"Place Finger Now";
    
    // Make sure flash is on
    AVCaptureDevice *device = nil;
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == AVCaptureDevicePositionBack && currentDevice.hasTorch) {
            device = currentDevice;
        }
    }
    
    if(device.torchActive == false) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
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
    
    [self.videoCamera stop];
    
}

-(void)dealloc {
    
    free(self.avgPixelIntensityBuffer);
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image {
    
    AVCaptureDevice *device = nil;
    
    NSArray* allDevices = [AVCaptureDevice devices];
    for (AVCaptureDevice* currentDevice in allDevices) {
        if (currentDevice.position == AVCaptureDevicePositionBack && currentDevice.hasTorch) {
            device = currentDevice;
        }
    }
    
    Mat image_copy;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    
    Scalar avgPixelIntensity = cv::mean( image_copy );
    
    if(avgPixelIntensity.val[0] < 75.0 && avgPixelIntensity.val[1] < 75.0 && avgPixelIntensity.val[2] > 150.0) {
        
        if(!self.initializedHR) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"Computing HR";
            });
        }

        if(!self.readingSamples) {
            self.readingSamples = true;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                           target:self
                                                         selector:@selector(_processSamples)
                                                         userInfo:nil
                                                          repeats:NO];
            });
        }
        if(self.readingSamples) {
            if(self.bufferIndex < kBufferLength && self.avgPixelIntensityBuffer != nil) {
                self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
                self.bufferIndex++;
            }
        }
        
    }
    else if(self.readingSamples) {
        self.readingSamples = false;
        
        [self clearBuffer];
        
        NSLog(@"buffer rest");
    }
    
    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
    if( self.bufferIndex >= kBufferLength ) {
        [self.timer invalidate];
        [self _processSamples ];
    }
    
}
#endif

- (void) _processSamples {
    
    NSLog(@"processing");
    self.readingSamples = false;
    
    for(int i=0; i<self.bufferIndex; i++) {
        NSLog(@"~~~ %f", self.avgPixelIntensityBuffer[i]);
    }
    
    float tempMax = 0.0;
    int tempMaxIndex = 0;
    
    for(int i = 0; i < self.bufferIndex - kWindowLength + 1; i++) {
        
        for(int j = 0; j < kWindowLength; j++) {
            
            if(self.avgPixelIntensityBuffer[i+j] >= tempMax && self.avgPixelIntensityBuffer[i+j] > 170) {
                tempMax = self.avgPixelIntensityBuffer[i+j];
                tempMaxIndex = j;
            }
            
        }
        
        if(tempMaxIndex == (kWindowLength/2)-1) {
            //dispatch_async(dispatch_get_main_queue(), ^{
            self.numBeats++;
            //});
        }
        
        tempMax = 0.0;
        
    }
    NSLog(@"%d", self.numBeats);
    dispatch_async(dispatch_get_main_queue(), ^{
       self.statusLabel.text = [NSString stringWithFormat:@"%d BPS", self.numBeats*3];
    });
    
    [self clearBuffer];
    
    for(int i=0; i<self.bufferIndex; i++) {
        NSLog(@"~ %f", self.avgPixelIntensityBuffer[i]);
    }
    
}

- (void) clearBuffer {
    self.numBeats = 0;
    
    free(self.avgPixelIntensityBuffer);
    
    self.avgPixelIntensityBuffer = (float*)calloc(kBufferLength,sizeof(float));
    self.bufferIndex = 0;
}

//#ifdef __cplusplus
//-(void) processImage:(Mat &)image {

//    AVCaptureDevice *device = nil;
//    
//    NSArray* allDevices = [AVCaptureDevice devices];
//    for (AVCaptureDevice* currentDevice in allDevices) {
//        if (currentDevice.position == AVCaptureDevicePositionBack && currentDevice.hasTorch) {
//            device = currentDevice;
//        }
//    }
//    
//    //NSLog(@"procesing");
//    
//    // Do some OpenCV stuff with the image
//    Mat image_copy;
//    
//    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
//    
//    Scalar avgPixelIntensity = cv::mean( image_copy );
    
//    if(avgPixelIntensity.val[0] < 50.0 && avgPixelIntensity.val[1] < 1.0) {
//        if(device.torchActive == false) {
//            [device lockForConfiguration:nil];
//            [device setTorchMode: AVCaptureTorchModeOn];
//            [device unlockForConfiguration];
//        }
//        if(self.timer == nil) {
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
//                                                 target:self
//                                               selector:@selector(printNumBeats:)
//                                               userInfo:nil
//                                                repeats:NO];
//            //[[NSRunLoop currentRunLoop] addTimer:t forMode:NSRunLoopCommonModes];

//            if(self.bufferIndex < kBufferLength && self.avgPixelIntensityBuffer != nil && !self.stopProcessing) {
//                //NSLog(@"Processing");
//                self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
//                self.bufferIndex++;
//            }
//        }
//        else if(self.bufferIndex < kBufferLength && self.avgPixelIntensityBuffer != nil && !self.stopProcessing) {
//            //NSLog(@"Processing");
//            self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
//            self.bufferIndex++;
//        }
    
//    }
//    
//    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
//
//}
//#endif

//-(void)printNumBeats: (NSTimer*) timer {
//    NSLog(@"Remove finger from camera lense");
//    [timer invalidate];
//    
//    //self.statusLabel.text = @"Remove finger from camera lense";
//    
//    
//    self.stopProcessing = true;
//    
//    float tempMax = 0.0;
//    int tempMaxIndex = 0;
//    
//    for(int i = 0; i < self.bufferIndex - kWindowLength + 1; i++) {
//        
//        for(int j = 0; j < kWindowLength; j++) {
//            
//            if(self.avgPixelIntensityBuffer[i+j] >= tempMax && self.avgPixelIntensityBuffer[i+j] > 170) {
//                tempMax = self.avgPixelIntensityBuffer[i+j];
//                tempMaxIndex = j;
//            }
//            
//        }
//        
//        if(tempMaxIndex == (kWindowLength/2)-1) {
//            //dispatch_async(dispatch_get_main_queue(), ^{
//                self.numBeats++;
//            //});
//        }
//        
//        tempMax = 0.0;
//        
//    }
//    NSLog(@"%d", self.numBeats);
//    
//    self.numBeats = 0;
//    
//    free(self.avgPixelIntensityBuffer);
//    
//    self.avgPixelIntensityBuffer = (float*)calloc(kBufferLength,sizeof(float));
//    self.bufferIndex = 0;
//}

@end
