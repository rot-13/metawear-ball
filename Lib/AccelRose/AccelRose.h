//
//  AccelRose.h
//  MetaWearBall
//
//  Created by Shay Davidson on 12/24/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetaWear/MetaWear.h>

@interface AccelRose : NSObject

- (void)update:(MBLAccelerometerData*)acceleration;

@end
