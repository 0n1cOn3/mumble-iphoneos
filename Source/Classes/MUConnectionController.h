// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *MUConnectionOpenedNotification;
extern NSString *MUConnectionClosedNotification;

@interface MUConnectionController : UIView
+ (MUConnectionController *) sharedController;
- (void) connectToHostname:(NSString *)hostName port:(NSUInteger)port withUsername:(NSString *)userName andPassword:(NSString *)password withParentViewController:(UIViewController *)parentViewController;
- (BOOL) isConnected;
- (void) disconnectFromServer;
@end
