//
//  BTLoginViewController.m
//  beaconTest
//
//  Created by Travis Heaver on 1/23/14.
//  Copyright (c) 2014 Travis Heaver. All rights reserved.
//

#import "BTLoginViewController.h"
#import "BTMainViewController.h"

@interface BTLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@property (strong, nonatomic) CLBeaconRegion *userBeaconRegion;
@property (nonatomic) BOOL setNumber;

@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;

@property (nonatomic, strong) NSMutableArray* queryResults;
@end

@implementation BTLoginViewController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;

}
-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToMainSegue" sender:self];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)loginButtonPressed:(UIButton *)sender
{
    NSLog(@"button pressed");
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships"
                                  , @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in error" message:@"Facebook login canceled" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alertView show];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in error" message:[error description] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToMainSegue" sender:self];
        }
    }];
}
#pragma mark - helper method

-(void) updateUserInformation
{
    
    NSLog(@"udate user information was called");
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSLog(@"request complete");
        if (!error) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSLog(@"%@",result);
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:9];
            
            if (userDictionary[@"name"]) {
                userProfile[kBTUserProfileNameKey] = userDictionary[kBTUserProfileNameKey];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kBTUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kBTUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]){
                userProfile[kBTUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]){
                
                userProfile[kBTUserProfileBirthdayKey] = userDictionary[@"birthday"];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                userProfile[kBTUserProfileAgeKey] = @(age);
            }
            
            if (userDictionary[@"interested_in"]){
                userProfile[kBTUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationshipStatus"]) {
                userProfile[kBTUserProfileRelationshipStatusKey] = userDictionary[kBTUserProfileRelationshipStatusKey];
            }
            
            if ([pictureURL absoluteString]){
                userProfile[kBTUserProfilePictureURL] = [pictureURL absoluteString];
            }

            [[PFUser currentUser] setObject:userProfile forKey:kBTUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
//            [self requestUserMajorMinor];
        }
        else{
            NSLog(@"Error in FB request %@", error);
        }
    }];
}

-(void) uploadPFFileToParse :(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData)
    {
        NSLog(@"Image data was not found");
        return;
    }
    
    NSLog(@"uploading to parse");
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *photo = [PFObject objectWithClassName:kBTPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kBTPhotoUserKey];
            [photo setObject:photoFile forKey:kBTPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"photo saved successfully");
            }];
        }
    }];
}


-(void) requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kBTPhotoClassKey];
    [query whereKey:kBTPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kBTUserProfileKey][kBTUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            if (!urlConnection) {
                NSLog(@"failed to download picture");
            }
        }
    }];
}
#pragma mark - segue
/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"loginToMainSegue"])
    {
        BTMainViewController *mainViewController = segue.destinationViewController;
        
        NSLog(@"about to segue with major value: %@", self.major);
        mainViewController.major = self.major;
        mainViewController.minor = self.minor;
    }
}
 */

#pragma mark - URL
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"picture loaded");
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}
@end
