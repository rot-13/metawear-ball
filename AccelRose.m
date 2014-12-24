//
//  AccelRose.m
//  MetaWearApiTest
//
//  Created by Shay Davidson on 12/24/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import "AccelRose.h"
#import "TCPSfx.h"

@interface AccelRose ()
@property (nonatomic) NSMutableArray *stream;
@property (nonatomic) BOOL didJump;
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
    if (self.prev) [self analyze:acceleration];
    [self.stream addObject:acceleration];
}

#pragma mark - Analysis

- (void)analyze:(MBLAccelerometerData*)acceleration {
    NSLog(@"%@", acceleration);
    int threshold = 150;
    if (!self.didJump && self.prev.RMS < threshold && acceleration.RMS < threshold) {
        [TCPSfx play:@"jump"];
        self.didJump = YES;
    } else if (self.didJump && self.prev.RMS < threshold && acceleration.RMS > threshold) {
        [TCPSfx play:@"land"];
        self.didJump = NO;
    } if (self.prev.RMS > 500 && acceleration.RMS > 750) {
        self.didJump = NO;
    }
}

#pragma mark - Helpers

- (MBLAccelerometerData*)prev {
    return self.stream.lastObject;
}

@end
