//
//  AccelRose.m
//  MetaWearBall
//
//  Created by Shay Davidson on 12/24/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import "AccelRose.h"
#import "TCPSfx.h"

@interface AccelRose ()
@property (nonatomic) NSMutableArray *stream;
@property (nonatomic) BOOL isFreeFalling;
@end

#define STREAM_CAPACITY 1000

@implementation AccelRose 

- (id)init {
    if (self = [super init]) {
        _stream = [[NSMutableArray alloc] initWithCapacity:STREAM_CAPACITY];
    }
    return self;
}

#pragma mark - API

- (void)update:(MBLAccelerometerData*)acceleration {
    [self print:acceleration];
    if (self.prev) [self analyze:acceleration];
    [self.stream addObject:acceleration];
}

#pragma mark - Analysis

- (void)analyze:(MBLAccelerometerData*)acceleration {
    int threshold = 150;
    if (!self.isFreeFalling && self.prev.RMS < threshold && acceleration.RMS < threshold) {
        [self startedFreeFall];
    } else if (self.isFreeFalling && self.prev.RMS < threshold && acceleration.RMS > threshold) {
        [self endedFreeFall];
    }
}

#pragma mark - Actions

- (void)startedFreeFall {
    [TCPSfx play:@"jump"];
    self.isFreeFalling = YES;
}

- (void)endedFreeFall {
    [TCPSfx play:@"land"];
    self.isFreeFalling = NO;
}

#pragma mark - Helpers

- (void)print:(MBLAccelerometerData*)acceleration {
    NSLog(@"%5d  [%4d, %4d, %4d]", acceleration.RMS, acceleration.x, acceleration.y, acceleration.z);
}

- (MBLAccelerometerData*)prev {
    return self.stream.lastObject;
}

@end
