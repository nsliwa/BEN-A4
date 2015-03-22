//
//  ModuleBViewController.h
//  TeamBEN-A4-ObjC
//
//  Created by ch484-mac4 on 3/17/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import <UIKit/UIKit.h>
// for callback: http://stackoverflow.com/questions/1015608/how-to-perform-callbacks-in-objective-c
@interface ModuleBViewController : UIViewController
{
    void (^_PPGHandler)(NSArray* ppg);
//    int (^_motionHandler)(void);
}

- (void) getPPGHandler:(void(^)(NSArray*))handler;

@end
