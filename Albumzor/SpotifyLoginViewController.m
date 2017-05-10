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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"spotifyAuthFailed" object:nil];
    self.firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    //move these checks to main container
    
    // Check if we have a token at all
    if (auth.session == nil) {
        return;
    }
    
    // Check if it's still valid
    if ([auth.session isValid] && self.firstLoad) {
        // It's still valid, show the player.
        [self loginSucceeded];
        return;
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
        NSLog(@"*** Failed to log in");
    }
}

- (void)loginSucceeded
{
    NSLog(@"Login complete");
    [_controllerDelegate loginSucceeded];
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


#pragma mark SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    NSLog(@"User canceled safari login dialogue");
}

#pragma mark - IBActions

- (IBAction)login {
    [self openLoginPage];
}


@end
