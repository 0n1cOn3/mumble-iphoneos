// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUConnectionController.h"
#import "MUServerRootViewController.h"
#import "MUServerCertificateTrustViewController.h"
#import "MUCertificateController.h"
#import "MUCertificateChainBuilder.h"
#import "MUDatabase.h"
#import "MUOperatingSystem.h"
#import "MUHorizontalFlipTransitionDelegate.h"

#import <MumbleKit/MKConnection.h>
#import <MumbleKit/MKServerModel.h>
#import <MumbleKit/MKCertificate.h>

NSString *MUConnectionOpenedNotification = @"MUConnectionOpenedNotification";
NSString *MUConnectionClosedNotification = @"MUConnectionClosedNotification";

@interface MUConnectionController () <MKConnectionDelegate, MKServerModelDelegate, MUServerCertificateTrustViewControllerProtocol> {
    MKConnection               *_connection;
    MKServerModel              *_serverModel;
    MUServerRootViewController *_serverRoot;
    UIViewController           *_parentViewController;
    UIAlertController          *_alertView;
    NSTimer                    *_timer;
    int                        _numDots;


    NSString                   *_hostname;
    NSUInteger                 _port;
    NSString                   *_username;
    NSString                   *_password;

    id                         _transitioningDelegate;
}
- (void) establishConnection;
- (void) teardownConnection;
- (void) showConnectingView;
- (void) hideConnectingView;
@end

@implementation MUConnectionController

+ (MUConnectionController *) sharedController {
    static MUConnectionController *nc;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        nc = [[MUConnectionController alloc] init];
    });
    return nc;
}

- (id) init {
    if ((self = [super init])) {
        if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
            _transitioningDelegate = [[MUHorizontalFlipTransitionDelegate alloc] init];
        }
    }
    return self;
}

- (void) dealloc {
    [super dealloc];

    [_transitioningDelegate release];
}

- (void) connetToHostname:(NSString *)hostName port:(NSUInteger)port withUsername:(NSString *)userName andPassword:(NSString *)password withParentViewController:(UIViewController *)parentViewController {
    _hostname = [hostName retain];
    _port = port;
    _username = [userName retain];
    _password = [password retain];
    
    [self showConnectingView];
    [self establishConnection];
    
    _parentViewController = [parentViewController retain];
}

- (BOOL) isConnected {
    return _connection != nil;
}

- (void) disconnectFromServer {
    [_serverRoot dismissModalViewControllerAnimated:YES];
    [self teardownConnection];
}

- (void) showConnectingView {
    NSString *title = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Connecting", nil)];
    NSString *msg = [NSString stringWithFormat:
                        NSLocalizedString(@"Connecting to %@:%lu", @"Connecting to hostname:port"),
                            _hostname, (unsigned long)_port];
    
    _alertView = [[UIAlertController alertControllerWithTitle:title
                                                     message:msg
                                              preferredStyle:UIAlertControllerStyleAlert] retain];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       [self teardownConnection];
                                                   }];
    [_alertView addAction:cancel];
    [_parentViewController presentViewController:_alertView animated:YES completion:nil];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(updateTitle) userInfo:nil repeats:YES];
}

- (void) hideConnectingView {
    [_alertView dismissViewControllerAnimated:YES completion:nil];
    [_alertView release];
    _alertView = nil;
    [_timer invalidate];
    _timer = nil;

    // This runloop wait works around a new behavior in iOS 7 where our UIAlertViews would suddenly
    // disappear if shown too soon after hiding the previous alert view.
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeInterval:0.350f sinceDate:[NSDate date]]];
}

- (void) establishConnection {
    _connection = [[MKConnection alloc] init];
    [_connection setDelegate:self];
    [_connection setForceTCP:[[NSUserDefaults standardUserDefaults] boolForKey:@"NetworkForceTCP"]];
    
    _serverModel = [[MKServerModel alloc] initWithConnection:_connection];
    [_serverModel addDelegate:self];
    
    _serverRoot = [[MUServerRootViewController alloc] initWithConnection:_connection andServerModel:_serverModel];
    
    // Set the connection's client cert if one is set in the app's preferences...
    NSData *certPersistentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultCertificate"];
    if (certPersistentId != nil) {
        NSArray *certChain = [MUCertificateChainBuilder buildChainFromPersistentRef:certPersistentId];
        [_connection setCertificateChain:certChain];
    }
    
    [_connection connectToHost:_hostname port:_port];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionOpenedNotification object:nil];
    });
}

- (void) teardownConnection {
    [_serverModel removeDelegate:self];
    [_serverModel release];
    _serverModel = nil;
    [_connection setDelegate:nil];
    [_connection disconnect];
    [_connection release]; 
    _connection = nil;
    [_timer invalidate];
    [_serverRoot release];
    _serverRoot = nil;
    
    // Reset app badge. The connection is no more.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MUConnectionClosedNotification object:nil];
    });
}
            
- (void) updateTitle {
    ++_numDots;
    if (_numDots > 3)
        _numDots = 0;

    NSString *dots = @"   ";
    if (_numDots == 1) { dots = @".  "; }
    if (_numDots == 2) { dots = @".. "; }
    if (_numDots == 3) { dots = @"..."; }
    
    _alertView.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Connecting", nil), dots];
}

#pragma mark - MKConnectionDelegate

- (void) connectionOpened:(MKConnection *)conn {
    NSArray *tokens = [MUDatabase accessTokensForServerWithHostname:[conn hostname] port:[conn port]];
    [conn authenticateWithUsername:_username password:_password accessTokens:tokens];
}

- (void) connection:(MKConnection *)conn closedWithError:(NSError *)err {
    [self hideConnectingView];
    if (err) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Connection closed", nil)
                                                                           message:[err localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self teardownConnection];
        }];
        [alertView addAction:ok];
        [_parentViewController presentViewController:alertView animated:YES completion:nil];
    }
}

- (void) connection:(MKConnection*)conn unableToConnectWithError:(NSError *)err {
    [self hideConnectingView];

    NSString *msg = [err localizedDescription];

    // errSSLClosedAbort: "connection closed via error".
    //
    // This is the error we get when users hit a global ban on the server.
    // Ideally, we'd provide better descriptions for more of these errors,
    // but when using NSStream's TLS support, the NSErrors we get are simply
    // OSStatus codes in an NSError wrapper without a useful description.
    //
    // In the future, MumbleKit should probably wrap the SecureTransport range of
    // OSStatus codes to improve this situation, but this will do for now.
    if ([[err domain] isEqualToString:NSOSStatusErrorDomain] && [err code] == -9806) {
        msg = NSLocalizedString(@"The TLS connection was closed due to an error.\n\n"
                                @"The server might be temporarily rejecting your connection because you have "
                                @"attempted to connect too many times in a row.", nil);
    }
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Unable to connect", nil)
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   [self teardownConnection];
                                               }];
    [alertView addAction:ok];
    [_parentViewController presentViewController:alertView animated:YES completion:nil];
}

// The connection encountered an invalid SSL certificate chain.
- (void) connection:(MKConnection *)conn trustFailureInCertificateChain:(NSArray *)chain {
    // Check the database whether the user trusts the leaf certificate of this server.
    NSString *storedDigest = [MUDatabase digestForServerWithHostname:[conn hostname] port:[conn port]];
    MKCertificate *cert = [[conn peerCertificates] objectAtIndex:0];
    NSString *serverDigest = [cert hexDigest];
    if (storedDigest) {
        if ([storedDigest isEqualToString:serverDigest]) {
            // Match
            [conn setIgnoreSSLVerification:YES];
            [conn reconnect];
            return;
        } else {
            // Mismatch.  The server is using a new certificate, different from the one it previously
            // presented to us.
            [self hideConnectingView];
            NSString *title = NSLocalizedString(@"Certificate Mismatch", nil);
            NSString *msg = NSLocalizedString(@"The server presented a different certificate than the one stored for this server", nil);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){ [self teardownConnection]; }];
            UIAlertAction *ignore = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ignore", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ [_connection setIgnoreSSLVerification:YES]; [_connection reconnect]; [self showConnectingView]; }];
            UIAlertAction *trust = [UIAlertAction actionWithTitle:NSLocalizedString(@"Trust New Certificate", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ MKCertificate *cert = [[_connection peerCertificates] objectAtIndex:0]; NSString *digest = [cert hexDigest]; [MUDatabase storeDigest:digest forServerWithHostname:[_connection hostname] port:[_connection port]]; [_connection setIgnoreSSLVerification:YES]; [_connection reconnect]; [self showConnectingView]; }];
            UIAlertAction *show = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show Certificates", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ MUServerCertificateTrustViewController *certTrustView = [[MUServerCertificateTrustViewController alloc] initWithCertificates:[_connection peerCertificates]]; [certTrustView setDelegate:self]; UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:certTrustView]; [certTrustView release]; [_parentViewController presentModalViewController:navCtrl animated:YES]; [navCtrl release]; }];
            [alert addAction:cancel];
            [alert addAction:ignore];
            [alert addAction:trust];
            [alert addAction:show];
            [_parentViewController presentViewController:alert animated:YES completion:nil];
        }
    } else {
        // No certhash of this certificate in the database for this hostname-port combo.  Let the user decide
        // what to do.
        [self hideConnectingView];
        NSString *title = NSLocalizedString(@"Unable to validate server certificate", nil);
        NSString *msg = NSLocalizedString(@"Mumble was unable to validate the certificate chain of the server.", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"Ignore", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Trust Certificate", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Show Certificates", nil)];
        [alert show];
        [alert release];
    }
}

// The server rejected our connection.
- (void) connection:(MKConnection *)conn rejectedWithReason:(MKRejectReason)reason explanation:(NSString *)explanation {
    NSString *title = NSLocalizedString(@"Connection Rejected", nil);
    NSString *msg = nil;
    UIAlertController *alert = nil;
    
    [self hideConnectingView];
    [self teardownConnection];
    
    switch (reason) {
        case MKRejectReasonNone:
            msg = NSLocalizedString(@"No reason", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            break;
        case MKRejectReasonWrongVersion:
            msg = @"Client/server version mismatch";
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];

            break;
        case MKRejectReasonInvalidUsername:
            msg = NSLocalizedString(@"Invalid username", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){ tf.text = _username; }];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            __weak UIAlertController *weakAlert = alert;
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reconnect", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *a){
                                                        [_username release];
                                                        _username = [[weakAlert.textFields[0] text] copy];
                                                        [self establishConnection];
                                                        [self showConnectingView];
                                                    }]];
            break;
        case MKRejectReasonWrongUserPassword:
            msg = NSLocalizedString(@"Wrong certificate or password for existing user", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){ tf.secureTextEntry = YES; tf.text = _password; }];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            __weak UIAlertController *weakAlertPW = alert;
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reconnect", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *a){
                                                        [_password release];
                                                        _password = [[weakAlertPW.textFields[0] text] copy];
                                                        [self establishConnection];
                                                        [self showConnectingView];
                                                    }]];
            break;
        case MKRejectReasonWrongServerPassword:
            msg = NSLocalizedString(@"Wrong server password", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){ tf.secureTextEntry = YES; tf.text = _password; }];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            __weak UIAlertController *weakAlertPW2 = alert;
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reconnect", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *a){
                                                        [_password release];
                                                        _password = [[weakAlertPW2.textFields[0] text] copy];
                                                        [self establishConnection];
                                                        [self showConnectingView];
                                                    }]];
            break;
        case MKRejectReasonUsernameInUse:
            msg = NSLocalizedString(@"Username already in use", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){ tf.text = _username; }];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
            __weak UIAlertController *weakAlert2 = alert;
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reconnect", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *a){
                                                        [_username release];
                                                        _username = [[weakAlert2.textFields[0] text] copy];
                                                        [self establishConnection];
                                                        [self showConnectingView];
                                                    }]];
            break;
        case MKRejectReasonServerIsFull:
            msg = NSLocalizedString(@"Server is full", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            break;
        case MKRejectReasonNoCertificate:
            msg = NSLocalizedString(@"A certificate is needed to connect to this server", nil);
            alert = [UIAlertController alertControllerWithTitle:title
                                                        message:msg
                                                 preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            break;
    }
    [_parentViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - MKServerModelDelegate

- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user {
    [MUDatabase storeUsername:[user userName] forServerWithHostname:[model hostname] port:[model port]];

    [self hideConnectingView];

    [_serverRoot takeOwnershipOfConnectionDelegate];

    [_username release];
    _username = nil;
    [_hostname release];
    _hostname = nil;
    [_password release];
    _password = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
            [_serverRoot setTransitioningDelegate:_transitioningDelegate];
        } else {
            [_serverRoot setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        }
    }

    [_parentViewController presentModalViewController:_serverRoot animated:YES];
    [_parentViewController release];
    _parentViewController = nil;
}


- (void) serverCertificateTrustViewControllerDidDismiss:(MUServerCertificateTrustViewController *)trustView {
    [self showConnectingView];
    [_connection reconnect];
}

@end
