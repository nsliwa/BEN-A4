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
#import "CustomQueue.h"

#define kFPS 30
#define kBufferLength 60*kFPS
#define kWindowLength 13

using namespace cv;

@interface ModuleBViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSTimer *timer;
@property (strong, nonatomic) CvVideoCameraMod *videoCamera;
@property (strong, nonatomic) NSMutableArray* avgPixelIntensityBuffer;
@property (nonatomic) int bufferIndex;
@property (nonatomic) int numBeats;
@property (nonatomic) bool queueSamples;
@property (nonatomic) bool initializedHR;
@property (nonatomic) int timeFraction;

@end

@implementation ModuleBViewController

//NSTimer *t;

-(bool)initializedHR {
    if(!_initializedHR) {
        _initializedHR = false;
    }
    
    return _initializedHR;
}

-(bool)queueSamples {
    if(!_queueSamples) {
        _queueSamples = false;
    }
    
    return _queueSamples;
}

-(int)numBeats {
    if(!_numBeats) {
        _numBeats = 0;
    }
    
    return _numBeats;
}

-(int)timeFraction {
    if(!_timeFraction) {
        _timeFraction = 1;
    }
    
    return _timeFraction;
}

-(int)bufferIndex {
    if(!_bufferIndex) {
        _bufferIndex = 0;
    }
    
    return _bufferIndex;
}

-(NSMutableArray*)avgPixelIntensityBuffer {
    if(!_avgPixelIntensityBuffer) {
        //_avgPixelIntensityBuffer = (float*)calloc(kBufferLength, sizeof(float));
        _avgPixelIntensityBuffer = [[NSMutableArray alloc] init];
    }
    
    return _avgPixelIntensityBuffer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ringBuffer = new RingBuffer(kBufferLength, 2);
    
    self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = kFPS;
    self.videoCamera.grayscaleMode = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.videoCamera start];
    
    //self.statusLabel.text = @"Place finger on camera lense";
    NSLog(@"Place finger on camera lense");
    self.statusLabel.text = @"Place Finger Now";
    
    self.initializedHR = false;
    
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

/*-(void)dealloc {
    
    free(self.avgPixelIntensityBuffer);
    
}*/

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
            self.initializedHR = true;
            self.timeFraction=1;
            self.numBeats = 0;
        }

        if(!self.queueSamples) {
            self.queueSamples = true;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                           target:self
                                                         selector:@selector(_processSamples)
                                                         userInfo:nil
                                                          repeats:NO];
            });
        }
        if(self.queueSamples) {
            if(self.bufferIndex < kBufferLength && self.avgPixelIntensityBuffer != nil) {
                //self.avgPixelIntensityBuffer[self.bufferIndex] = avgPixelIntensity.val[2];
                [self.avgPixelIntensityBuffer enqueue: [NSNumber numberWithFloat: avgPixelIntensity.val[2]]];
                self.bufferIndex++;
            }
            else if(self.bufferIndex == kBufferLength) {
                [self.avgPixelIntensityBuffer dequeue];
                [self.avgPixelIntensityBuffer enqueue: [NSNumber numberWithFloat: avgPixelIntensity.val[2]]];
            }
        }
        
    }
    else if(self.queueSamples) {
        self.queueSamples = false;
        [self.timer invalidate];
        
        [self clearBuffer];
        if(self.numBeats > 0) {
            int tempFrac = self.timeFraction;
            if(self.bufferIndex < kBufferLength) { tempFrac = self.timeFraction -1; }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = [NSString stringWithFormat:@"%.1f BPM", self.numBeats*(4.0/tempFrac)];
            });
            self.initializedHR = false;
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"Place Finger Now";
            });
            self.initializedHR = false;
        }
        
        NSLog(@"buffer reset");
    }
    
    cvtColor(image_copy, image, CV_BGR2BGRA); //add back for display
    
//    if( self.bufferIndex >= kBufferLength ) {
//        [self.timer invalidate];
//        [self _processSamples ];
//    }
    
}
#endif

- (void) _processSamples {
    
    NSLog(@"processing");
//    self.queueSamples = false;
    
    for(int i=0; i<self.bufferIndex; i++) {
        NSLog(@"~~~ %@", [self.avgPixelIntensityBuffer objectAtIndex:i]);
    }
    
    float tempMax = 0.0;
    int tempMaxIndex = 0;
    self.numBeats = 0;
    
    for(int i = 0; i < self.bufferIndex - kWindowLength + 1; i++) {
        
        for(int j = 0; j < kWindowLength; j++) {
            
            if([[self.avgPixelIntensityBuffer objectAtIndex:(i+j)] floatValue] >= tempMax && [[self.avgPixelIntensityBuffer objectAtIndex:(i+j)] floatValue] > 170) {
                tempMax = [[self.avgPixelIntensityBuffer objectAtIndex:(i+j)] floatValue];
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
    NSLog(@"beats: %d, frac: %d", self.numBeats, self.timeFraction);
    int tempFrac = self.timeFraction;
    dispatch_async(dispatch_get_main_queue(), ^{
       self.statusLabel.text = [NSString stringWithFormat:@"%.1f BPM", self.numBeats*(4.0/tempFrac)];
    });
    
//    [self clearBuffer];
    
//    for(int i=0; i<self.bufferIndex; i++) {
//        NSLog(@"~ %f", [[self.avgPixelIntensityBuffer objectAtIndex:(i)] floatValue]);
//    }
    
    if(self.bufferIndex < kBufferLength) {
        self.timeFraction++;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                   target:self
                                                 selector:@selector(_processSamples)
                                                 userInfo:nil
                                                  repeats:NO];
    });
    
}

- (void) clearBuffer {
//    self.numBeats = 0;
    
   // free(self.avgPixelIntensityBuffer);
    
    //self.avgPixelIntensityBuffer = (float*)calloc(kBufferLength,sizeof(float));
    self.bufferIndex = 0;
    [self.avgPixelIntensityBuffer removeAllObjects];
}


@end
