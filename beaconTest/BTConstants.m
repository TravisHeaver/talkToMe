//
//  BTConstants.m
//  beaconTest
//
//  Created by Travis Heaver on 1/19/14.
//  Copyright (c) 2014 Travis Heaver. All rights reserved.
//

#import "BTConstants.h"

@implementation BTConstants

NSString *const kUUIDtalkToMe = @"AABB0012-3243-CDCD-AABA-102929383940";

NSString *const kTalkToMeIdentifier = @"talkToMeIdentifier";


#pragma mark - user class
NSString *const kBTUserTageLineKey              = @"tagLine";

NSString *const kBTUserProfileKey               = @"profile";
NSString *const kBTUserProfileNameKey           = @"name";
NSString *const kBTUserProfileFirstNameKey      = @"firstName";
NSString *const kBTUserProfileLocationKey       = @"location";
NSString *const kBTUserProfileGenderKey         = @"gender";
NSString *const kBTUserProfileBirthdayKey       = @"birthday";
NSString *const kBTUserProfileInterestedInKey   = @"interestedIn";
NSString *const kBTUserProfilePictureURL        = @"pictureURL";

NSString *const kBTUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kBTUserProfileAgeKey            = @"age";

#pragma mark - photo class
NSString *const kBTPhotoClassKey                = @"Photo";
NSString *const kBTPhotoUserKey                 = @"user";
NSString *const kBTPhotoPictureKey              = @"image";

@end
