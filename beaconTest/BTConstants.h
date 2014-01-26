//
//  BTConstants.h
//  beaconTest
//
//  Created by Travis Heaver on 1/19/14.
//  Copyright (c) 2014 Travis Heaver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTConstants : NSObject



extern NSString *const kUUIDtalkToMe;

extern NSString *const kTalkToMeIdentifier;


#pragma mark - user profile

extern NSString *const kBTUserTageLineKey;

extern NSString *const kBTUserProfileKey;
extern NSString *const kBTUserProfileNameKey;
extern NSString *const kBTUserProfileFirstNameKey;
extern NSString *const kBTUserProfileLocationKey;
extern NSString *const kBTUserProfileGenderKey;
extern NSString *const kBTUserProfileBirthdayKey;
extern NSString *const kBTUserProfileInterestedInKey;
extern NSString *const kBTUserProfilePictureURL;

extern NSString *const kBTUserProfileRelationshipStatusKey;
extern NSString *const kBTUserProfileAgeKey;

#pragma mark - photo class
extern NSString *const kBTPhotoClassKey;
extern NSString *const kBTPhotoUserKey;
extern NSString *const kBTPhotoPictureKey;
@end
