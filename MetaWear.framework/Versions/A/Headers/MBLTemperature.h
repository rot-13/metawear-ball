/**
 * MBLTemperature.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/1/14.
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

@class MBLMetaWear;

typedef NS_OPTIONS(uint8_t, MBLTemperatureSource) {
    MBLTemperatureSourceInternal,
    MBLTemperatureSourceThermistor
};

typedef NS_OPTIONS(uint8_t, MBLTemperatureUnit) {
    MBLTemperatureUnitCelsius,
    MBLTemperatureUnitFahrenheit
};

/**
 Interface to the on-chip and external thermistor temperature sensors
 */
@interface MBLTemperature : MBLModule

/**
 Sampling period for temperature readings in mSec
 */
@property (nonatomic) uint16_t samplePeriod;
/**
 changeEvents occur when the temprature changes by this delta
 */
@property (nonatomic) float delta;
/**
 thresholdEvents occur when the temprature rises above or falls below this threshold
 */
@property (nonatomic) float upperThreshold;
/**
 thresholdEvents occur when the temprature rises above or falls below this threshold
 */
@property (nonatomic) float lowerThreshold;

/**
 Choose where temperature readings are taken from, note that MBLTemperatureSourceThermistor
 requires installing an external thermistor and setting the thermistorReadPin
 and thermistorEnablePin properties
 */
@property (nonatomic) MBLTemperatureSource source;
/**
 Thermistor output pin number
 */
@property (nonatomic) uint8_t thermistorReadPin;
/**
 Thermistor enable pin number
 */
@property (nonatomic) uint8_t thermistorEnablePin;

/**
 Choose between celsius and fahrenheit
 */
@property (nonatomic) MBLTemperatureUnit units;


/**
 Perform a one time read of the current device temperature
 @param handler Callback once temperature read is complete
 */
- (void)readTemperatureWithHandler:(MBLDecimalNumberHandler)handler;

/**
 Event representing a new temperature data sample. This event will
 occur every samplePeriod milliseconds. Event callbacks will be provided an
 NSDecimalNumber object.
 */
@property (nonatomic, strong, readonly) MBLEvent *dataReadyEvent;

/**
 Event representing a temperature change by delta degrees. The temperature
 is checked against the delta every samplePeriod milliseconds.  Event callbacks
 will be provided an NSDecimalNumber object.
 */
@property (nonatomic, strong, readonly) MBLEvent *changeEvent;

/**
 Event representing a temperature threshold crossing. The temperature
 is checked against the threshold every samplePeriod milliseconds.  Event 
 callbacks will be provided an NSDecimalNumber object.
 */
@property (nonatomic, strong, readonly) MBLEvent *thresholdEvent;

@end
