/**
 * DeviceDetailViewController.h
 * MetaWearBall
 */

#import <UIKit/UIKit.h>
#import <MetaWear/MetaWear.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DeviceDetailViewController : UIViewController

@property (strong, nonatomic) MBLMetaWear *device;

@end
