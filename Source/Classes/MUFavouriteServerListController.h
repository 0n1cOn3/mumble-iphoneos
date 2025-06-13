// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MUFavouriteServer.h"

@interface MUFavouriteServerListController : UITableViewController <UIActionSheetDelegate>
- (id) init;
- (void) dealloc;
- (void) presentNewFavouriteDialog;
- (void) presentEditDialogForFavourite:(MUFavouriteServer *)favServ;
@end
