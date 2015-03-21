//
//  CustomQueue.h
//  TeamBEN-A4-ObjC
//
//  Created by Nicole Sliwa on 3/21/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//
// Code taken from: https://github.com/esromneb/ios-queue-object/blob/master/NSMutableArray%2BQueueAdditions.h

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

-(id) dequeue;
-(void) enqueue:(id)obj;
-(id) peek:(int)index;
-(id) peekHead;
-(id) peekTail;
-(BOOL) empty;

@end
