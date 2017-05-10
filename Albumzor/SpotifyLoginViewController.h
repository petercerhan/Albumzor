//
//  SpotifyLoginViewController.h
//  Login
//
//  Created by Peter Cerhan on 5/8/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SafariServices/SafariServices.h>

@protocol SpotifyLoginViewControllerDelegate

-(void)loginComplete: (bool)success;

@end

@interface SpotifyLoginViewController : UIViewController

@end
