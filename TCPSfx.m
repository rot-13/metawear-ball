//
//  TCPSfx.m
//  teacup
//
//  Created by Yonatan Bergman on 25/02/14.
//  Copyright (c) 2014 IIC. All rights reserved.
//

#import "TCPSfx.h"
#import <AVFoundation/AVFoundation.h>

#define SOUND_EXT @"caf"

@implementation TCPSfx

static AVAudioPlayer *audioPlayer = nil;
static BOOL areSoundsSupppressed = NO;

+ (void)play:(NSString*)sound {
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:sound withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:resourceURL error: nil];
    [audioPlayer play];
}

+ (void)suppressSounds {
    areSoundsSupppressed = YES;
}

+ (void)resumeSounds {
    areSoundsSupppressed = NO;
}

+ (void)configureAmbientSession:(NSError **)error {
    [self configureSession:AVAudioSessionCategoryAmbient error:error];
}

+ (void)configurePlaybackSession:(NSError **)error {
    [self configureSession:AVAudioSessionCategoryPlayback error:error];
}

+ (void)configurePlayAndRecordSession:(NSError **)error {
    [self configureSession:AVAudioSessionCategoryPlayAndRecord error:error];
}

+ (void)configureSession:(NSString *)sessionCategory error:(NSError **)error {
    [[AVAudioSession sharedInstance] setCategory:sessionCategory error:error];
    [self configureSpeakerOverride];
}

+ (void)configureSpeakerOverride {
    // Route audio to speakers unless headphones plugged in
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([self isUsingHeadphones]) {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    } else {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
}

+ (BOOL)isUsingHeadphones {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in route.outputs) {
        if ([desc.portType isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

@end
