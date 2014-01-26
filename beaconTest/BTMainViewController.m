//
//  BTMainViewController.m
//  beaconTest
//
//  Created by Travis Heaver on 1/19/14.
//  Copyright (c) 2014 Travis Heaver. All rights reserved.
//

#import "BTMainViewController.h"
#import "CoreBluetooth/CoreBluetooth.h"
#import "CoreLocation/CoreLocation.h"
#import "BTConstants.h"

@interface BTMainViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIApplicationDelegate>
@property (strong, nonatomic) IBOutlet UIButton *startSendingButton;
@property (strong, nonatomic) IBOutlet UIButton *startListeningButton;
@property (strong, nonatomic) IBOutlet UILabel *feedbackLabel;

@property (strong, nonatomic) UILocalNotification *localNotification;
@property (nonatomic) NSNumber *numberOfUsers;

//used for listening
@property (nonatomic, strong) CLLocationManager *locationManager;
//used for braudcasting
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;

@property (nonatomic) BOOL isBraudcasting;
@property (nonatomic) BOOL isSearching;

//@property (nonatomic, strong) NSNumber *major;
//@property (nonatomic, strong) NSNumber *minor;

@end

@implementation BTMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"view did load iphone");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    self.localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];

//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self requestUserMajorMinor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createRegion
{
    if (self.beaconRegion) return;
    //the sending and receiving uuids could be different. But in our case we want the UUID we are looking for to be
    //one specific UUID. We then parse out the major and minor values
    //identifier is used within the application ....only? not sent

    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUIDtalkToMe];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kTalkToMeIdentifier];
    
}
-(void)createRegionWithValues:(NSString *)uuidString
                        major:(CLBeaconMajorValue *)major
                        minor:(CLBeaconMinorValue *)minor
{
    NSUUID *regionUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    
    CLBeaconRegion *userBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:regionUUID major:1 minor:2 identifier:@"userBeaconIdentifier"];
    
    self.beaconRegion = userBeaconRegion;
}

-(void)returnNumberOfUsers
{
    PFQuery *userCountQuery = [PFUser query];
    [userCountQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"the number of users is: %i", number);
        //self.numberOfUsers = number;
    }];
    
}


-(void)startBraudcasting
{
    NSString *userID =  [[PFUser currentUser] objectId];
    NSLog(@"The current user id user name is: %@", userID);

    
    NSLog(@"minor: %@", self.minor);
    NSLog(@"major: %@", self.major);
    
    NSLog(@"major value about to create the beacon region: %@", self.major);
    
    CLBeaconMinorValue minor = [self.minor shortValue];
    CLBeaconMinorValue major = [self.major shortValue];
    
    [self createRegionWithValues:kUUIDtalkToMe major:&major minor:&minor];
    //turn on ther peripheral manager
    if (!self.peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    }
    
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Periferal manager state is not powered on");
        return;
    }
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                           major:[self.major shortValue]
                                                                           minor:4
                                                                      identifier:kTalkToMeIdentifier];
    NSDictionary *beaconData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconData];
    NSLog(@"started braudcasting...");
    self.isBraudcasting = YES;
    self.startSendingButton.backgroundColor = [UIColor greenColor];
}
-(void)stopBraudcasting
{
    [self.peripheralManager stopAdvertising];
    self.isBraudcasting = NO;
    NSLog(@"Stoped braudcasting");
    self.startSendingButton.backgroundColor = [UIColor yellowColor];
}
- (IBAction)startSendingButtonPressed:(id)sender {
    if (!self.isBraudcasting) {
        [self startBraudcasting];
        
    }
    else{
        [self stopBraudcasting];
    }
}
-(void)lookForBeacons
{
    NSLog(@"starting to look for beacons");
    if(![CLLocationManager isRangingAvailable])
    {
        NSLog(@"ranging is not available");
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"ranging is alrady on");
        return;
    }
    
    [self createRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"ranging for beacon: %@", self.beaconRegion);
}

#pragma mark listening
-(void)startListening
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.detectedBeacons = [NSArray array];
    
    [self lookForBeacons];
    
}
-(void)startRanging
{
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUIDtalkToMe];
    CLBeaconRegion *regionRanging = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kTalkToMeIdentifier];
    regionRanging.notifyOnEntry = YES;
    regionRanging.notifyOnExit = YES;
    regionRanging.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startRangingBeaconsInRegion:regionRanging];
    NSLog(@"started ranging beacons in region: %@",regionRanging.proximityUUID.UUIDString);
}
-(void)stopListening
{
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}
-(void)stopRanging
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}
- (IBAction)startListeningButtonPressed:(id)sender {
    if (self.isSearching) {
        [self stopListening];
        [self stopRanging];
        self.startListeningButton.backgroundColor = [UIColor yellowColor];
        self.isSearching = NO;
    }
    else{
        [self startListening];
        [self startRanging];
        self.startListeningButton.backgroundColor = [UIColor greenColor];
        self.isSearching = YES;
    }
}
#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        self.isBraudcasting = NO;
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising: %@", peripheralManager.description);
        self.isBraudcasting = YES;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        self.isBraudcasting = NO;
        return;
    }
    
    NSLog(@"Peripheral manager is on.");
    [self startBraudcasting];
}

#pragma mark - Beacon Ranging delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"did change authorization status");
    if(![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"location services are not enabled");
        self.isSearching = NO;
        return;
    }
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"location services not authorized");
        self.isSearching = NO;
        return;
    }
    self.isSearching = YES;
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"did range beacons");
    CLBeacon *beacon = [[CLBeacon alloc] init];
    NSUInteger numberOfBeacons = [beacons count];
    
    for (NSInteger i = 0; i<numberOfBeacons; i++) {
        beacon = [beacons objectAtIndex:i];
        NSLog(@"The UUID is: %@", beacon.proximityUUID.UUIDString);
        NSLog(@"The major value is: %@", beacon.major);
        NSLog(@"The minor value is: %@", beacon.minor);
        
        self.feedbackLabel.text = beacon.proximityUUID.UUIDString;
    }
}
#pragma mark - Beacon enter region delegate
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    
    NSLog(@"The UUID: %@", [region.proximityUUID UUIDString]);
    NSLog(@"The UUID major: %@i", region.major);
    NSLog(@"The UUID major: %@i", region.minor);
    NSLog(@"entered a reagon: %@",region.identifier);
    
    
    self.feedbackLabel.text = [[NSString alloc] initWithFormat:@"entered region: %@",region.identifier];
    
    if ([region isEqual:self.beaconRegion]) {
        NSLog(@"they are equal");
    }
    
    //set notification to user
    [self setNotification:region];
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"did exit reagion: %@",region.identifier);
    self.feedbackLabel.text = [[NSString alloc] initWithFormat:@"exited region: %@",region.identifier];
}

#pragma mark - local notification
-(void)setNotification:(CLBeaconRegion *)note
{
    NSLog(@"setting up notification");
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
    notification.alertBody = [NSString stringWithFormat:@"Alert! entered region with UUID"];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

    
    NSLog(@"about to send notification");
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  //  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    NSLog(@"notification sent");
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"Local notification received");
}

#pragma mark - getting and setting beacon major minor values
//we neet to set the properties of the user, need to check if the user already has these values
//if they do use them, if not set them
-(void) requestUserMajorMinor
{
    PFQuery *queryForMajorMinor = [PFQuery queryWithClassName:@"UUID"];
    [queryForMajorMinor whereKey:@"user" equalTo:[PFUser currentUser]];
    
    //check to see if the user has these values set
    [queryForMajorMinor findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            [self getNumberOfUserMajorMinorValues];
        }
        else{
            self.major = [NSNumber numberWithInt:[objects[0][@"major"] intValue]];
            NSLog(@"the BT major value is: %@", self.major);
            self.startSendingButton.enabled = true;
        }
    }];
}

-(void) returnUserMajorValue
{
    PFQuery *query = [PFQuery queryWithClassName:@"UUID"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@",objects);
        
        self.major = [NSNumber numberWithInt:[objects[0][@"major"] intValue]];
        NSLog(@"the BT major value is: %@", self.major);
    }];
}

-(void) getNumberOfUserMajorMinorValues
{
    PFQuery *queryForNumberOfUUID = [PFQuery queryWithClassName:@"UUID"];
    [queryForNumberOfUUID countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"the number of uuid values is %i", number);
        NSNumber *num = [[NSNumber alloc] initWithInt:number];
        
        self.numberOfUsers = num;
        [self setUserMajorMinorValues];
    }];
}
-(void) setUserMajorMinorValues
{
    PFObject *setUserMinorValue = [PFObject objectWithClassName:@"UUID"];
    [setUserMinorValue setObject:[PFUser currentUser] forKey:@"user"];
    [setUserMinorValue setObject:self.numberOfUsers forKey:@"major"];
    [setUserMinorValue saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"saved the user major value: %@", self.numberOfUsers);
        self.major = self.numberOfUsers;
        self.startSendingButton.enabled = true;
    }];
}
@end
