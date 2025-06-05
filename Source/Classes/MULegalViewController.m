// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MULegalViewController.h"
#import "MUOperatingSystem.h"
#import <WebKit/WebKit.h>

@interface MULegalViewController () <WKNavigationDelegate> {
    WKWebView *_webView;
}
@end

@implementation MULegalViewController

- (void)loadView {
    [super loadView];
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    [self.view addSubview:_webView];
}

- (id) init {
    if ((self = [super init])) {
        // ...
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.navigationDelegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = NSLocalizedString(@"Legal", nil);

    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        navBar.tintColor = [UIColor whiteColor];
        navBar.translucent = NO;
        navBar.backgroundColor = [UIColor blackColor];
    }
    navBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = done;
    [done release];

    NSData *html = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Legal" ofType:@"html"]];
    [_webView loadData:html MIMEType:@"text/html" characterEncodingName:@"utf-8" baseURL:nil];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    _webView.backgroundColor = [UIColor blackColor];
    _webView.opaque = YES;
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}

- (void) doneButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
