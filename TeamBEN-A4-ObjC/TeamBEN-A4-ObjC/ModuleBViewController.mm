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
#define kWindowLength 20

using namespace cv;

@interface ModuleBViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (nonatomic) float upBeatIntensity;
@property (nonatomic) float downBeatIntensity;
@property (nonatomic) float *avgPixelIntensityBuffer;
@property (nonatomic) int bufferIndex;
@property (nonatomic) int numBeats;
@property (nonatomic) bool stopProcessing;

@end

@implementation ModuleBViewController

NSTimer *t;

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

-(void)dealloc {
    
    free(self.avgPixelIntensityBuffer);
    
}

#ifdef __cplusplus
-(void) processImage:(Mat &)image {
    
    //NSLog(@"procesing");
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    
    Scalar avgPixelIntensity = cv::mean( image_copy );
    if(avgPixelIntensity.val[0] < 50.0 && avgPixelIntensity.val[1] < 1.0) {
        
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
            
            if(t == nil) {
                t = [NSTimer scheduledTimerWithTimeInterval: 60.0
                            target: self
                            selector:@selector(printNumBeats:)
                            userInfo: nil
                            repeats:NO];
            }
            
            if(self.bufferIndex < kBufferLength && self.avgPixelIntensityBuffer != nil && !self.stopProcessing) {
                self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
                self.bufferIndex++;
            }
            
        }
        
    }
    
    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display

}
#endif

-(void)printNumBeats: (NSTimer*) timer {
    
    self.stopProcessing = true;
    
    float tempMax = 0.0;
    int tempMaxIndex = 0;
    
    for(int i = 0; i < kBufferLength; i++) {
        
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
    
    self.numBeats = 0;
    
    free(self.avgPixelIntensityBuffer);
    
    self.avgPixelIntensityBuffer = (float*)calloc(kBufferLength,sizeof(float));
    self.bufferIndex = 0;
}

@end
