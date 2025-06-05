// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUVersionChecker.h"

# update-network-classes-to-use-nsurlsession
@interface MUVersionChecker () <NSURLSessionDataDelegate> {
    NSURLSession         *_session;
    NSURLSessionDataTask *_task;
    NSMutableData        *_buf;
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
=======
@interface MUVersionChecker () {
    NSURLSessionDataTask *_task;
}
- (void) newBuildAvailable;
@end

@implementation MUVersionChecker

- (id) init {
    self = [super init];
    if (!self)
        return nil;

# update-network-classes-to-use-nsurlsession
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mumble-ios.appspot.com/latest.plist"]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil] retain];
    _task = [[_session dataTaskWithRequest:req] retain];
    _buf = [[NSMutableData alloc] init];
=======
    NSURL *url = [NSURL URLWithString:@"https://mumble-ios.appspot.com/latest.plist"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __block typeof(self) bself = self;
    _task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSLog(@"MUversionChecker: failed to fetch latest version info.");
            return;
        }
        [bself parseData:data];
    }];
    [_task resume];

    return self;
}

- (void) dealloc {
    [_task cancel];
    [_task release];
# update-network-classes-to-use-nsurlsession
    [_session invalidateAndCancel];
    [_session release];
    [_buf release];
    [super dealloc];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_buf appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"MUversionChecker: failed to fetch latest version info.");
        return;
    }

=======
    [super dealloc];
}

- (void)parseData:(NSData *)data {
    NSPropertyListFormat fmt = NSPropertyListXMLFormat_v1_0;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:0 format:&fmt error:nil];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:msg
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Upgrade", nil), nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // Upgrade
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://mumble-ios.appspot.com/wdist/manifest"]];
    }
}

@end
