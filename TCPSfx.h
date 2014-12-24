//
//  TCPSfx.h
//  teacup
//
//  Created by Yonatan Bergman on 25/02/14.
//  Copyright (c) 2014 IIC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPSfx : NSObject
+ (void) play:(NSString*)sound;

+ (void)configureAmbientSession:(NSError **)error;

+ (void)configurePlaybackSession:(NSError **)error;

+ (void)configurePlayAndRecordSession:(NSError **)error;

@end
