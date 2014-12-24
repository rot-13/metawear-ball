/**
 * DeviceDetailViewController.m
 * MetaWearApiTest
*/

#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import "APLGraphView.h"
#import "TCPSfx.h"

@interface DeviceDetailViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *connectionSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerScale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleFrequency;
@property (weak, nonatomic) IBOutlet UISwitch *highPassFilterSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hpfCutoffFreq;
@property (weak, nonatomic) IBOutlet UISwitch *lowNoiseSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activePowerScheme;
@property (weak, nonatomic) IBOutlet UISwitch *autoSleepSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepSampleFrequency;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepPowerScheme;
@property (nonatomic) int lastRMS;

@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerGraph;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;

@property (weak, nonatomic) IBOutlet UIButton *startAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *stopAccelerometer;

@property (strong, nonatomic) UIView *grayScreen;
@property (strong, nonatomic) NSArray *accelerometerDataArray;
@property (nonatomic) BOOL accelerometerRunning;
@property (nonatomic) BOOL switchRunning;
@property (nonatomic) BOOL didJump;
@end

@implementation DeviceDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.grayScreen = [[UIView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120)];
    self.grayScreen.backgroundColor = [UIColor grayColor];
    self.grayScreen.alpha = 0.4;
    [self.view addSubview:self.grayScreen];
    
    [self.stopAccelerometer setEnabled:NO];
    self.lastRMS = 1000000;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.device addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self connectDevice:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.device removeObserver:self forKeyPath:@"state"];

    if (self.accelerometerRunning) {
        [self stopAccelerationPressed:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.device.state == CBPeripheralStateDisconnected) {
        [self setConnected:NO];
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
    }
}

- (void)setConnected:(BOOL)on
{
    [self.connectionSwitch setOn:on animated:YES];
    [self.grayScreen setHidden:on];
}

- (void)connectDevice:(BOOL)on
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (on) {
        hud.labelText = @"Connecting...";
        [self.device connectWithHandler:^(NSError *error) {
            [self setConnected:(error == nil)];
            hud.mode = MBProgressHUDModeText;
            if (error) {
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:2];
            } else {
                hud.labelText = @"Connected!";
                [hud hide:YES afterDelay:0.5];
            }
        }];
    } else {
        hud.labelText = @"Disconnecting...";
        [self.device disconnectWithHandler:^(NSError *error) {
            [self setConnected:NO];
            hud.mode = MBProgressHUDModeText;
            if (error) {
                hud.labelText = error.localizedDescription;
                [hud hide:YES afterDelay:2];
            } else {
                hud.labelText = @"Disconnected!";
                [hud hide:YES afterDelay:0.5];
            }
        }];
    }
}

- (IBAction)connectionSwitchPressed:(id)sender
{
    [self connectDevice:self.connectionSwitch.on];
}

- (IBAction)readBatteryPressed:(id)sender
{
    [self.device readBatteryLifeWithHandler:^(NSNumber *number, NSError *error) {
        self.batteryLevelLabel.text = [number stringValue];
    }];
}

- (void)updateAccelerometerSettings
{
    if (self.accelerometerScale.selectedSegmentIndex == 0) {
        self.accelerometerGraph.fullScale = 2;
    } else if (self.accelerometerScale.selectedSegmentIndex == 1) {
        self.accelerometerGraph.fullScale = 4;
    } else {
        self.accelerometerGraph.fullScale = 8;
    }
    
    self.device.accelerometer.fullScaleRange = (int)self.accelerometerScale.selectedSegmentIndex;
    self.device.accelerometer.sampleFrequency = (int)self.sampleFrequency.selectedSegmentIndex;
    self.device.accelerometer.highPassFilter = self.highPassFilterSwitch.on;
    self.device.accelerometer.filterCutoffFreq = self.hpfCutoffFreq.selectedSegmentIndex;
    self.device.accelerometer.lowNoise = self.lowNoiseSwitch.on;
    self.device.accelerometer.activePowerScheme = (int)self.activePowerScheme.selectedSegmentIndex;
    self.device.accelerometer.autoSleep = self.autoSleepSwitch.on;
    self.device.accelerometer.sleepSampleFrequency = (int)self.sleepSampleFrequency.selectedSegmentIndex;
    self.device.accelerometer.sleepPowerScheme = (int)self.sleepPowerScheme.selectedSegmentIndex;
}

- (IBAction)startAccelerationPressed:(id)sender
{
    [self updateAccelerometerSettings];
    
    [self.startAccelerometer setEnabled:NO];
    [self.stopAccelerometer setEnabled:YES];
    self.accelerometerRunning = YES;
    // These variables are used for data recording
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerDataArray = array;

    
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandler:^(MBLAccelerometerData *acceleration, NSError *error) {
        NSLog(@"%@", acceleration);
        int threshold = 150;
        if (!self.didJump && self.lastRMS < threshold && acceleration.RMS < threshold) {
            [TCPSfx play:@"jump"];
            self.didJump = YES;
        } else if (self.didJump && self.lastRMS < threshold && acceleration.RMS > threshold) {
            [TCPSfx play:@"land"];
            self.didJump = NO;
        } if (self.lastRMS > 500 && acceleration.RMS > 750) {
            self.didJump = NO;
        }
        self.lastRMS = acceleration.RMS;
        [self.accelerometerGraph addX:(float)acceleration.x / 1000.0 y:(float)acceleration.y / 1000.0 z:(float)acceleration.z / 1000.0];
        // Add data to data array for saving
        [array addObject:acceleration];
    }];
}

- (IBAction)stopAccelerationPressed:(id)sender
{
    [self.device.accelerometer.dataReadyEvent stopNotifications];
    self.accelerometerRunning = NO;

    [self.startAccelerometer setEnabled:YES];
    [self.stopAccelerometer setEnabled:NO];
}



@end
