//
//  SpotifyLoginViewController.m
//  Login
//
//  Created by Peter Cerhan on 5/8/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

#import "SpotifyLoginViewController.h"

@interface SpotifyLoginViewController () <SFSafariViewControllerDelegate>

@property (atomic, readwrite) UIViewController *authViewController;
@property (atomic, readwrite) BOOL firstLoad;

@end

@implementation SpotifyLoginViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    
    if(_spotifyConnected) {
        [_messageLabel setText:@"Please refresh your Spotify authentication"];
    }
    
    [[_spotifyButton layer] setCornerRadius:25.0];
}

- (void)openLoginPage
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if ([SPTAuth supportsApplicationAuthentication]) {
        [[UIApplication sharedApplication] openURL:[auth spotifyAppAuthenticationURL] options:@{} completionHandler:nil];
    } else {
        self.authViewController = [self authViewControllerWithURL:[[SPTAuth defaultInstance] spotifyWebAuthenticationURL]];
        self.definesPresentationContext = YES;
        [self presentViewController:self.authViewController animated:YES completion:nil];
    }
}

- (UIViewController *)authViewControllerWithURL:(NSURL *)url
{
    UIViewController *viewController;
    if ([SFSafariViewController class]) {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
        safari.delegate = self;
        viewController = safari;
    }

    viewController.modalPresentationStyle = UIModalPresentationPageSheet;
    return viewController;
}

- (void)sessionUpdatedNotification:(NSNotification *)notification
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (auth.session && [auth.session isValid]) {
        [self loginSucceeded];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not Log In!"
                                                                       message:@"Unable to authenticate your Spotify account"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:dismissAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)loginSucceeded
{
    [_controllerDelegate loginSucceeded];
}

-(void)cancelLogin
{
    [_controllerDelegate cancelLogin];
}

#pragma mark SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    //Do nothing
}

#pragma mark - IBActions

- (IBAction)login {
    [self openLoginPage];
}

- (IBAction)cancel {
    [[self controllerDelegate] cancelLogin];
}

@end
