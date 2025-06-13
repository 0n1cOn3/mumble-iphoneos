// Copyright 2009-2012 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUDataURL.h"
#import <Foundation/Foundation.h>

@implementation MUDataURL

// todo(mkrautz): Redo this with our own internal scanning and base64 decoding
// to get rid of the string copying.
+ (NSData *) dataFromDataURL:(NSString *)dataURL {
    if (![dataURL hasPrefix:@"data:"])
        return nil;

    NSString *afterPrefix = [dataURL substringFromIndex:5];
    NSRange semiRange = [afterPrefix rangeOfString:@";"];
    if (semiRange.location == NSNotFound)
        return nil;

    NSString *rest = [afterPrefix substringFromIndex:semiRange.location];
    NSString *token = @";base64,";
    if (![rest hasPrefix:token])
        return nil;

    NSString *base64Part = [rest substringFromIndex:[token length]];
    base64Part = [base64Part stringByRemovingPercentEncoding];
    base64Part = [base64Part stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:base64Part options:0];
    return decoded;
}

+ (UIImage *) imageFromDataURL:(NSString *)dataURL {
    return [UIImage imageWithData:[MUDataURL dataFromDataURL:dataURL]];
}

@end
