// Copyright 2009-2012 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface MUMessageAttachmentViewController : UITableViewController
- (id) initWithImages:(NSArray *)images andLinks:(NSArray *)links;
@end
