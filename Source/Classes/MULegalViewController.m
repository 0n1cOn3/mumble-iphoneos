// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MULegalViewController.h"
#import "MUOperatingSystem.h"
#import <WebKit/WebKit.h>

@interface MULegalViewController () <WKNavigationDelegate> {
    IBOutlet WKWebView *_webView;
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

- (void)dealloc {
    [_webView release];
    [super dealloc];
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view = view;
    [view release];

    _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _webView.frame = self.view.bounds;
}

- (void) viewDidLoad {
    [super viewDidLoad];
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

    NSData *html = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Legal" ofType:@"html"]];
    [_webView loadData:html MIMEType:@"text/html" characterEncodingName:@"utf-8" baseURL:nil];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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
