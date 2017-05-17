//
//  SpotifyManager.m
//  Login
//
//  Created by Peter Cerhan on 5/8/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

#import "SpotifyAuthManager.h"
#import <SpotifyAuthentication/SpotifyAuthentication.h>

@implementation SpotifyAuthManager

-(void)configureSpotifyAuth {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"config.txt" ofType:nil];
    NSString *clientIDFromFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *clientID = [clientIDFromFile stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = clientID;
    auth.requestedScopes = @[SPTAuthUserReadPrivateScope];
    auth.redirectURL = [NSURL URLWithString:@"com.cerhan.albumzor://"];

    auth.sessionUserDefaultsKey = @"SpotifySession";
}

-(bool)openURL: (NSURL *)url {
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.sessionUserDefaultsKey = @"SpotifySession";
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error) {
//            NSLog(@"*** Auth error: %@", error);
        } else {
            auth.session = session;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

-(bool)sessionIsValid {
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.sessionUserDefaultsKey = @"SpotifySession";
    
    // Check if we have a token at all
    if (auth.session == nil) {
        return NO;
    }
    
    // Check if it's still valid
    if ([auth.session isValid]) {
        return YES;
    }
    
    return NO;
}

-(NSString *)getToken {
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.sessionUserDefaultsKey = @"SpotifySession";
    return auth.session.accessToken;
}

@end

