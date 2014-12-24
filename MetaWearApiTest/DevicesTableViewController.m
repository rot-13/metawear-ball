/**
 * DevicesTableViewController.m
 * MetaWearApiTest
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import "DevicesTableViewController.h"
#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import <MetaWear/MetaWear.h>

@interface DevicesTableViewController ()
@property (nonatomic, strong) NSArray *devices;
@property (strong, nonatomic) UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UISwitch *scanningSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *metaBootSwitch;
@end

@implementation DevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.center = CGPointMake(95, 138);
    [self.tableView addSubview:self.activity];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setScanning:self.scanningSwitch.on];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setScanning:NO];
}

- (void)setScanning:(BOOL)on
{
    if (on) {
        [self.activity startAnimating];
        if (self.metaBootSwitch.on) {
            [[MBLMetaWearManager sharedManager] startScanForMetaBootsAllowDuplicates:YES handler:^(NSArray *array) {
                self.devices = array;
                [self.tableView reloadData];
            }];
        } else {
            [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
                self.devices = array;
                [self.tableView reloadData];
            }];
        }
    } else {
        [self.activity stopAnimating];
        if (self.metaBootSwitch.on) {
            [[MBLMetaWearManager sharedManager] stopScanForMetaBoots];
        } else {
            [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
        }
    }
}

- (IBAction)scanningSwitchPressed:(UISwitch *)sender
{
    [self setScanning:sender.on];
}

- (IBAction)metaBootSwitchPressed:(id)sender
{
    if (self.metaBootSwitch.on) {
        [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
    } else {
        [[MBLMetaWearManager sharedManager] stopScanForMetaBoots];
    }
    // Wait a split second for any final callbacks to fire before starting up scanning again
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.devices = nil;
        [self.tableView reloadData];
        [self setScanning:self.scanningSwitch.on];
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = self.metaBootSwitch.on ? @"MetaBootCell" : @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    MBLMetaWear *cur = self.devices[indexPath.row];
    
    UILabel *uuid = (UILabel *)[cell viewWithTag:1];
    uuid.text = cur.identifier.UUIDString;
    
    UILabel *rssi = (UILabel *)[cell viewWithTag:2];
    rssi.text = [cur.discoveryTimeRSSI stringValue];
    
    UILabel *connected = (UILabel *)[cell viewWithTag:3];
    if (cur.state == CBPeripheralStateConnected) {
        [connected setHidden:NO];
    } else {
        [connected setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MBLMetaWear *selected = self.devices[indexPath.row];
    if (self.metaBootSwitch.on) {
        [self.scanningSwitch setOn:NO animated:YES];
        [self.metaBootSwitch setOn:NO animated:YES];
        [self metaBootSwitchPressed:self.metaBootSwitch];
        // Pause the screen while update is going on
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        hud.labelText = @"Updating...";
        [selected updateFirmwareWithHandler:^(NSError *error) {
            hud.mode = MBProgressHUDModeText;
            if (error) {
                NSLog(@"Firmware update error: %@", error.localizedDescription);
                [[[UIAlertView alloc] initWithTitle:@"Update Error"
                                            message:[@"Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: " stringByAppendingString:error.localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil] show];
                [hud hide:YES];
            } else {
                hud.labelText = @"Success!";
                [hud hide:YES afterDelay:2.0];
            }
        } progressHandler:^(float number, NSError *error) {
            if (number != hud.progress) {
                hud.progress = number;
                if (number == 1.0) {
                    hud.mode = MBProgressHUDModeIndeterminate;
                    hud.labelText = @"Resetting...";
                }
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"DeviceDetails" sender:selected];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Devices";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DeviceDetailViewController *destination = segue.destinationViewController;
    destination.device = sender;
}

@end
