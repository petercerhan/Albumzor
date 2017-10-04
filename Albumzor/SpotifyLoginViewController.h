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

-(void)loginSucceeded;
-(void)cancelLogin;

@end

@interface SpotifyLoginViewController : UIViewController

@property (weak) id <SpotifyLoginViewControllerDelegate> controllerDelegate;
@property BOOL spotifyConnected;

@property IBOutlet UILabel *messageLabel;
@property IBOutlet UIButton *spotifyButton;
@property IBOutlet UIButton *cancelButton;

@end
