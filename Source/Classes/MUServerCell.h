// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <MumbleKit/MKServerPinger.h>

@class MUFavouriteServer;

@interface MUServerCell : UITableViewCell <MKServerPingerDelegate>
+ (NSString *) reuseIdentifier;
- (void) populateFromDisplayName:(NSString *)displayName hostName:(NSString *)hostName port:(NSString *)port;
- (void) populateFromFavouriteServer:(MUFavouriteServer *)favServ;
@end
