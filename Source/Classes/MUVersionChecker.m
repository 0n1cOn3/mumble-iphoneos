// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUVersionChecker.h"

@interface MUVersionChecker () {
    NSURLSessionDataTask *_task;
    NSMutableData   *_buf;
}
- (void)newBuildAvailable;
@end

@implementation MUVersionChecker

- (id) init {
    self = [super init];
    if (!self)
        return nil;

    NSURL *url = [NSURL URLWithString:@"http://mumble-ios.appspot.com/latest.plist"];
    _buf = [[NSMutableData alloc] init];
    __block id blockSelf = [self retain];
    _task = [[[NSURLSession sharedSession] dataTaskWithURL:url
                                         completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        if (data && !error) {
            [_buf appendData:data];
            [blockSelf parseData];
        }
        [blockSelf release];
    }] retain];
    [_task resume];

    return self;
}

- (void) dealloc {
    [_task cancel];
    [_task release];
    [_buf release];
    [super dealloc];
}

- (void)parseData {
    NSPropertyListFormat fmt = NSPropertyListXMLFormat_v1_0;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:_buf options:0 format:&fmt error:nil];
    if (dict) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *ourRev = [mainBundle objectForInfoDictionaryKey:@"MumbleGitRevision"];
        NSString *latestRev = [dict objectForKey:@"MumbleGitRevision"];
        if (![ourRev isEqualToString:latestRev]) {
            NSDate *ourBuildDate = [mainBundle objectForInfoDictionaryKey:@"MumbleBuildDate"];
            NSDate *latestBuildDate = [dict objectForKey:@"MumbleBuildDate"];
            if (![ourBuildDate isEqualToDate:latestBuildDate]) {
                NSDate *latest = [ourBuildDate laterDate:latestBuildDate];
                if (latestBuildDate == latest) {
                    [self newBuildAvailable];
                }
            }
        }
    }
}

- (void) newBuildAvailable {
    NSString *title = NSLocalizedString(@"New beta build available", nil);
    NSString *msg = NSLocalizedString(@"Do you want to upgrade?", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *upgrade = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://mumble-ios.appspot.com/wdist/manifest"]];
                                                    }];
    [alert addAction:cancel];
    [alert addAction:upgrade];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}



@end
