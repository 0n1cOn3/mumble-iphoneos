// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MUCertificateCreationProgressView : UIViewController
- (id) initWithName:(NSString *)name email:(NSString *)email;
- (void) dealloc;
@end