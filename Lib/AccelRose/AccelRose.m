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

#define FREEFALL_RMS_THREHOLD 150

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
    [self.stream addObject:acceleration];
    [self analyze];
}

#pragma mark - Analysis

- (void)analyze {
    if (!self.isFreeFalling && [self last:2 underRMS:FREEFALL_RMS_THREHOLD]) {
        [self startedFreeFall];
    } else if (self.isFreeFalling && [self last:2 aboveRMS:FREEFALL_RMS_THREHOLD]) {
        [self endedFreeFall];
    }
}

- (BOOL)last:(int)last underRMS:(int)underRMS {
    return [self last:last complyTo:^BOOL(MBLAccelerometerData *data) {
        return data.RMS < underRMS;
    }];
}

- (BOOL)last:(int)last aboveRMS:(int)aboveRMS {
    return [self last:last complyTo:^BOOL(MBLAccelerometerData *data) {
        return data.RMS > aboveRMS;
    }];
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

- (BOOL)last:(int)last complyTo:(BOOL(^)(MBLAccelerometerData *data))complyTo {
    if (self.stream.count < last) return false;
    
    NSArray *tail = [self.stream subarrayWithRange:NSMakeRange(self.stream.count-last, last)];
    for (MBLAccelerometerData* data in tail) {
        if (!complyTo(data)) return false;
    }
    return true;
}

@end
