/**
 * MBLANCS.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/17/14.
 * Copyright 2014 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms . The License limits your use, and you acknowledge,
 * that the  Software may not be modified, copied or distributed and can be used
 * solely and exclusively in conjunction with a MbientLab Inc, product.  Other
 * than for the foregoing purpose, you may not use, reproduce, copy, prepare
 * derivative works of, modify, distribute, perform, display or sell this
 * Software and/or its documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab Inc, at www.mbientlab.com.
 */

#import <MetaWear/MBLConstants.h>
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLModule.h>

@class MBLANCSEvent;

typedef NS_OPTIONS(uint16_t, MBLANCSCategoryID) {
    MBLANCSCategoryIDOther              = 1 << 0,
    MBLANCSCategoryIDIncomingCall       = 1 << 1,
    MBLANCSCategoryIDMissedCall         = 1 << 2,
    MBLANCSCategoryIDVoicemail          = 1 << 3,
    MBLANCSCategoryIDSocial             = 1 << 4,
    MBLANCSCategoryIDSchedule           = 1 << 5,
    MBLANCSCategoryIDEmail              = 1 << 6,
    MBLANCSCategoryIDNews               = 1 << 7,
    MBLANCSCategoryIDHealthAndFitness   = 1 << 8,
    MBLANCSCategoryIDBusinessAndFinance = 1 << 9,
    MBLANCSCategoryIDLocation           = 1 << 10,
    MBLANCSCategoryIDEntertainment      = 1 << 11,
    MBLANCSCategoryIDAny                = 0xFFFF
};

typedef NS_OPTIONS(uint8_t, MBLANCSEventID) {
    MBLANCSEventIDNotificationAdded    = 1 << 0,
    MBLANCSEventIDNotificationModified = 1 << 1,
    MBLANCSEventIDNotificationRemoved  = 1 << 2,
    MBLANCSEventIDAny                  = 0xFF
};

typedef NS_OPTIONS(uint8_t, MBLANCSEventFlag) {
    MBLANCSEventFlagSilent         = 1 << 0,
    MBLANCSEventFlagImportant      = 1 << 1,
    MBLANCSEventFlagPreExisting    = 1 << 2,
    MBLANCSEventFlagPositiveAction = 1 << 3,
    MBLANCSEventFlagNegativeAction = 1 << 4,
    MBLANCSEventFlagAny            = 0
};

typedef NS_ENUM(uint8_t, MBLANCSNotificationAttributeID) {
    MBLANCSNotificationAttributeIDAppIdentifier       = 0,
    MBLANCSNotificationAttributeIDTitle               = 1,
    MBLANCSNotificationAttributeIDSubtitle            = 2,
    MBLANCSNotificationAttributeIDMessage             = 3,
    MBLANCSNotificationAttributeIDMessageSize         = 4,
    MBLANCSNotificationAttributeIDDate                = 5,
    MBLANCSNotificationAttributeIDPositiveActionLabel = 6,
    MBLANCSNotificationAttributeIDNegativeActionLabel = 7,
    MBLANCSNotificationAttributeIDNone                = 0xFF
};

@interface MBLANCS : MBLModule

@end
