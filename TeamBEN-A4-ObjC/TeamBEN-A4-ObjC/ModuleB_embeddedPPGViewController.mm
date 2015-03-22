//
//  ModuleB_embeddedFrequencyViewController.m
//  TeamBEN-A2
//
//  Created by Nicole Sliwa on 2/18/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "ModuleB_embeddedPPGViewController.h"
#import "ModuleBViewController.h"

#import "SMUGraphHelper.h"

#import <math.h>

extern NSArray* sharedBuffer;

#define kBufferLength 300
#define kframesPerSecond 30
#define knumDataArraysToGraph 1

//#define kSamplingRate 44100.00 //Hz
//#define kBufferL 8192//4096
//#define kSpectrumLength kBufferLength/2
//#define kdf kSamplingRate/kBufferLength
//


//#define kSubSetLength 25
//#define kThrowAway 20
//#define kCalibrate 20

@interface ModuleB_embeddedFrequencyViewController ()
/*
// UI properties
@property (weak, nonatomic) IBOutlet UILabel *label_Frequency;
@property (weak, nonatomic) IBOutlet UILabel *label_Gesture;

@property (weak, nonatomic) IBOutlet UISlider *slider_Frequency;
*/

// Processing properties
@property (strong, nonatomic) ModuleBViewController* masterView;
@property (nonatomic)GraphHelper *graphHelper;

//@property (nonatomic)float *fftMagnitudeBuffer;
//@property (nonatomic)float *fftPhaseBuffer;
//
//@property (nonatomic)float *fftMagnitudeBufferAvg;
//@property (nonatomic)float *fftMagnitudeBufferSubset;
//
//@property (nonatomic)float outputFrequencyPrevious;
//
//@property (strong, nonatomic)NSMutableArray *fftVariance_left;
//@property (strong, nonatomic)NSMutableArray *fftVariance_right;

@property (nonatomic)float* data;


@end

@implementation ModuleB_embeddedFrequencyViewController

-(GraphHelper*) graphHelper {
    if(!_graphHelper) {
        _graphHelper = new GraphHelper(self,
                                       kframesPerSecond,
                                       knumDataArraysToGraph,
                                       PlotStyleSeparated);
    }
    return _graphHelper;
}

//-(ModuleBViewController*)masterView{
//    if(!_masterView)
//        _masterView = [ModuleBViewController sharedInstance];
//    return _masterView;
//}

-(float*) data {
    if(!_data)
        _data = (float *)calloc(kBufferLength,sizeof(float));
    return _data;
}
//
//-(float*) fftMagnitudeBuffer {
//    if(!_fftMagnitudeBuffer)
//        _fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
//    return _fftMagnitudeBuffer;
//}
//
//-(float*) fftPhaseBuffer {
//    if(!_fftPhaseBuffer)
//        _fftPhaseBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
//    return _fftPhaseBuffer;
//}
//
//-(float*) fftMagnitudeBufferAvg {
//    if(!_fftMagnitudeBufferAvg)
//        _fftMagnitudeBufferAvg = (float *)calloc(kBufferLength/2,sizeof(float));
//    return _fftMagnitudeBufferAvg;
//}
//
//-(float*) fftMagnitudeBufferSubset {
//    if(!_fftMagnitudeBufferSubset)
//        _fftMagnitudeBufferSubset = (float *)calloc(kSubSetLength,sizeof(float));
//    return _fftMagnitudeBufferSubset;
//}
//
//-(NSMutableArray*) fftVariance_left {
//    if(!_fftVariance_left)
//        _fftVariance_left = [[NSMutableArray alloc]init];
//    return _fftVariance_left;
//}
//-(NSMutableArray*) fftVariance_right {
//    if(!_fftVariance_right)
//        _fftVariance_right = [[NSMutableArray alloc]init];
//    return _fftVariance_right;
//}
//
//-(float) outputFrequency {
//    if(!_outputFrequency)
//        _outputFrequency = 1;
//    return _outputFrequency;
//}
//
//-(float) outputFrequencyPrevious {
//    if(!_outputFrequencyPrevious)
//        _outputFrequencyPrevious = 0;
//    return _outputFrequencyPrevious;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //float frequency = self.slider_Frequency.value;
    //self.label_Frequency.text = [NSString stringWithFormat:@"%.02f kHz", frequency / 1000.0];
    // Do any additional setup after loading the view.
    
    self.graphHelper->SetBounds(-1,0.5,-0.5,0.5); // bottom, top, left, right, full screen==(-1,1,-1,1)
}

#pragma mark - GLKView

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


#pragma mark - unloading and dealloc
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // stop opengl from running
    self.graphHelper->tearDownGL();
}

-(void)dealloc{
    self.graphHelper->tearDownGL();
    
//    free(self.fftMagnitudeBuffer);
//    free(self.fftPhaseBuffer);
//    
//    free(self.fftMagnitudeBufferAvg);
//    free(self.fftMagnitudeBufferSubset);
    
    delete self.graphHelper;
    
    self.graphHelper = nil;
    
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}


#pragma mark - OpenGL and Update functions
//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    //get current Frequency
//    ModuleBViewController *master = [[ModuleBViewController alloc] init];
    
//    __block float* data;
    
//    [self.masterView getPPGHandler:^(NSArray* graphData){
//        int counter = 0;
//        for(id frame in graphData) {
//            self->_data[counter] = [frame floatValue];
//            counter++;
//        }
//        NSLog(@"data: %d", counter);
//    }];
    int counter = 0;
    for(id frame in sharedBuffer) {
        self.data[counter] = [frame floatValue];
        counter++;
    }
    
    self.graphHelper->setGraphData(1,self.data,kBufferLength,sqrt(kBufferLength)); // set graph channel
    
    
    
//    self.outputFrequencyPrevious = self.outputFrequency;
//    self.outputFrequency = freq;
//    
//    // plot the audio
//    ringBuff->FetchFreshData2(self.audioData, kBufferLength, 0, 1);
//    
//    //take the FFT
//    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
//    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer2, self.fftPhaseBuffer2);
//    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer3, self.fftPhaseBuffer3);
//    [self removeVarianceInMagnitude];
//    [self convertToDecibels];
//    //[self findMaxUsingDilation];
//    
//    float frequencyIndex = self.outputFrequency;
//    frequencyIndex /= kdf;
//    int frequencyIdx = floor(frequencyIndex);
//    
//    //NSLog(@"frequencyIndex: %f, frequencyIdx: %d, outputFreq: %d, kdf: %f", frequencyIndex, frequencyIdx, (int)floor(self.outputFrequency), kdf);
//    
//    
//    for(int i=0; i<kSubSetLength; i++) {
//        if(frequencyIdx - kSubSetLength/2 < 0) {
//            self.fftMagnitudeBufferSubset[i] = self.fftMagnitudeBufferAvg[i];
//            //NSLog(@"@1:");
//        }
//        else if(frequencyIdx + kSubSetLength/2 > kBufferLength/2) {
//            self.fftMagnitudeBufferSubset[i] = self.fftMagnitudeBufferAvg[ kBufferLength/2 - kSubSetLength + i];
//            //NSLog(@"@2:");
//        }
//        else {
//            self.fftMagnitudeBufferSubset[i] = self.fftMagnitudeBufferAvg[frequencyIdx - kSubSetLength/2 + i];
//            //NSLog(@"@3:");
//        }
//    }
//    
//    //NSLog(@"",self.)
//    
//    
//    // plot the FFT
//    //self.graphHelper->setGraphData(0,self.fftMagnitudeBufferAvg,kBufferLength/2,sqrt(kBufferLength));
//    self.graphHelper->setGraphData(0,self.fftMagnitudeBufferSubset,kSubSetLength,sqrt(kSubSetLength)); // set graph channel
//    //self.graphHelper->setGraphData(1,self.fftMagnitudeBuffer2,kBufferLength/8,sqrt(kBufferLength));
//    //self.graphHelper->setGraphData(2,self.fftMagnitudeBuffer3,kBufferLength/8,sqrt(kBufferLength));
//    
//    if(self.outputFrequency == self.outputFrequencyPrevious && self.throwAwayCount == kCalibrate + kThrowAway)
//    {
//        int nNearestFreq = kSubSetLength / 2;
//        
//        float peakBaseline = 0;
//        float peak = 0;
//        float peakBaseline_left = 0;
//        float peakBaseline_right = 0;
//        float peak_left = 0;
//        float peak_right = 0;
//        
//        for(int i=kSubSetLength/2 - nNearestFreq; i<kSubSetLength/2 + nNearestFreq; i++) {
//            if(i < kSubSetLength/2) {
//                if(peak_left < self.fftMagnitudeBufferSubset[i]) {
//                    peak_left = self.fftMagnitudeBufferSubset[i];
//                }
//                if(peakBaseline_left < self.fftMagnitudeBufferSubsetBaseline[i]) {
//                    peakBaseline_left = self.fftMagnitudeBufferSubsetBaseline[i];
//                }
//            }
//            else if (i > kSubSetLength/2) {
//                if(peak_right < self.fftMagnitudeBufferSubset[i]) {
//                    peak_right = self.fftMagnitudeBufferSubset[i];
//                }
//                if(peakBaseline_right < self.fftMagnitudeBufferSubsetBaseline[i]) {
//                    peakBaseline_right = self.fftMagnitudeBufferSubsetBaseline[i];
//                }
//            }
//            else if (i == kSubSetLength/2) {
//                peakBaseline = self.fftMagnitudeBufferSubsetBaseline[i];
//                peak = self.fftMagnitudeBufferSubset[i];
//            }
//            else {
//                NSLog(@"Should never go in here!!");
//            }
//            
//        }
//        
//        int maxIdx = 0;
//        float maxFreq = 0;
//        
//        for(int i=0; i<kSubSetLength; i++) {
//            self.fftMagnitudeBufferSubsetDifference[i] = self.fftMagnitudeBufferSubset[i] - self.fftMagnitudeBufferSubsetBaseline[i];
//            //self.fftMagnitudeBufferSubsetDifference[i] /= peak;
//            
//            if(self.fftMagnitudeBufferSubsetDifference[i] > maxFreq) {
//                maxFreq = self.fftMagnitudeBufferSubsetDifference[i];
//                maxIdx = i;
//            }
//        }
//        
//        self.graphHelper->setGraphData(1,self.fftMagnitudeBufferSubsetDifference,kSubSetLength,sqrt(kSubSetLength)); // set graph channel
//        
//        
//        ModuleB_MasterVIewControllerViewController *parent = (ModuleB_MasterVIewControllerViewController *)self.parentViewController;
//        
//        /*
//        if(maxIdx > kSubSetLength/2 +2 && self.fftMagnitudeBufferSubsetDifference[maxIdx] > self.rightThreshold*1.1) {
//            NSLog(@"maxIdx: %d, difference: %f, trueThreshold: %f", maxIdx, self.fftMagnitudeBufferSubsetDifference[maxIdx], self.rightThreshold);
//            NSLog(@"TOWARD");
//            dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"TOWARD";});
//        }
//        else if(maxIdx < kSubSetLength/2 -2 && self.fftMagnitudeBufferSubsetDifference[maxIdx] > self.leftThreshold*1.1) {
//            NSLog(@"maxIdx: %d, difference: %f, trueThreshold: %f", maxIdx, self.fftMagnitudeBufferSubsetDifference[maxIdx], self.leftThreshold);
//            NSLog(@"AWAY");
//            dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"AWAY";});
//        }
//        else {
//            NSLog(@"maxIdx: %d, difference: %f, rightThreshold: %f, leftThreshold: %f", maxIdx, self.fftMagnitudeBufferSubsetDifference[maxIdx], self.rightThreshold, self.leftThreshold);
//            NSLog(@"-----");
//            dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"STATIONARY";});
//        }
//         */
//        
//        
//        if(self.fftMagnitudeBufferSubsetDifference[maxIdx] > 4) {
//            if(maxIdx > kSubSetLength/2 +2) {
//                if(self.gesturePrevious == 1) {
//                    NSLog(@"TOWARD");
//                    dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"TOWARD";});
//                }
//                self.gesturePrevious = 1;
//            }
//            else if(maxIdx < kSubSetLength/2 -2) {
//                if(self.gesturePrevious == -1) {
//                    NSLog(@"AWAY");
//                    dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"AWAY";});
//                }
//                self.gesturePrevious = -1;
//            }
//        }
//        else {
//            if(self.gesturePrevious == 0) {
//                NSLog(@"-----");
//                dispatch_async(dispatch_get_main_queue(), ^ {parent.label_Gesture.text = @"STATIONARY";});
//            }
//            self.gesturePrevious = 0;
//        }
//    }
//    else {
//        NSLog(@"Frequency Tone Changed");
//        
//        if(self.throwAwayCount == kThrowAway + kCalibrate) {
//            self.throwAwayCount = 0;
//        }
//        
//        self.throwAwayCount++;
//        
//        if(self.throwAwayCount > kThrowAway) {
//            for(int i=0; i<kSubSetLength; i++) {
//                self.fftMagnitudeBufferSubsetBaseline[i] = self.fftMagnitudeBufferSubset[i];
//            }
//            
//            if(self.throwAwayCount <= kThrowAway + kCalibrate) {
//                float max = 0;
//                for(int j=0; j<kSubSetLength/2; j++) {
//                    if(self.fftMagnitudeBufferSubset[j] > max) {
//                        max = self.fftMagnitudeBufferSubset[j];
//                    }
//                }
//                self.leftThreshold += max;
//                
//                max = 0;
//                for(int j=kSubSetLength/2 + 3; j<kSubSetLength; j++) {
//                    if(self.fftMagnitudeBufferSubset[j] > max) {
//                        max = self.fftMagnitudeBufferSubset[j];
//                    }
//                }
//                self.rightThreshold +=max;
//            }
//            if(self.throwAwayCount == kThrowAway + kCalibrate) {
//                self.leftThreshold /= kCalibrate;
//                self.rightThreshold /= kCalibrate;
//            }
//        }
//    }
    
}





@end
