// Copyright 2012 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MUCertificateChainBuilder : NSObject
+ (NSArray *) buildChainFromPersistentRef:(NSData *)persistentRef;
@end
