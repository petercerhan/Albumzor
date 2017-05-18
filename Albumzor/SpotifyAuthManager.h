//
//  SpotifyManager.h
//  Login
//
//  Created by Peter Cerhan on 5/8/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyAuthManager : NSObject

-(void)configureSpotifyAuth;
-(bool)openURL: (NSURL *)url;
-(bool)sessionIsValid;
-(NSString *)getToken;
-(void)deleteSession;

@end
