// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUPublicServerList.h"
#import <MumbleKit/MKServices.h>

@interface MUPublicServerList () {
    NSData              *_serverListXML;
    NSMutableDictionary *_continentCountries;
    NSMutableDictionary *_countryServers;
    NSDictionary        *_continentNames;
    NSDictionary        *_countryNames;
    NSMutableArray      *_modelContinents;
    NSMutableArray      *_modelCountries;
    BOOL                _parsed;
}
+ (NSString *) filePath;
@end


@interface MUPublicServerListFetcher () <NSURLSessionDataDelegate> {
    NSURLSession           *_session;
    NSURLSessionDataTask   *_task;
    NSMutableData          *_buf;
@interface MUPublicServerListFetcher () {
    NSURLSessionDataTask *_task;
}
@end

@implementation MUPublicServerListFetcher

- (id) init {
    if ((self = [super init])) {
        // ...
    }
    return self;
}

- (void) dealloc {
    [_task cancel];
    [_task release];
    [_session invalidateAndCancel];
    [_session release];
    [_buf release];
    [super dealloc];
}

- (void) attemptUpdate {
    NSURL *url = [MKServices regionalServerListURL];
    NSURLSession *session = [NSURLSession sharedSession];
    __block id blockSelf = [self retain];
    _task = [[session dataTaskWithURL:url
                    completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        if (data && !error) {
            [data writeToFile:[MUPublicServerList filePath] atomically:YES];
        }
        [blockSelf release];
    }] retain];
    [_task resume];
}

    #update-network-classes-to-use-nsurlsession
    NSURLRequest *req = [NSURLRequest requestWithURL:[MKServices regionalServerListURL]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil] retain];
    _task = [[_session dataTaskWithRequest:req] retain];
    _buf = [[NSMutableData alloc] init];
    [_task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_buf appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [_buf writeToFile:[MUPublicServerList filePath] atomically:YES];
    }
    [_buf release];
    _buf = nil;
    [_task release];
    _task = nil;
    [_session finishTasksAndInvalidate];
    [_session release];
    _session = nil;
}

    NSURL *url = [MKServices regionalServerListURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __block typeof(self) bself = self;
    _task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            [data writeToFile:[MUPublicServerList filePath] atomically:YES];
        }
    }];
    [_task resume];
}
@end


@implementation MUPublicServerList

+ (NSString *) filePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
    NSString *directory = [documentDirectories objectAtIndex:0];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    return [directory stringByAppendingPathComponent:@"publist.xml"];
}

- (id) init {
    if ((self = [super init])) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[MUPublicServerList filePath]]) {
            _serverListXML = [[NSData alloc] initWithContentsOfFile:[MUPublicServerList filePath]];
        } else {
            _serverListXML = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"publist" ofType:@"xml"]];
        }
        
        _continentNames = [[NSDictionary alloc] initWithContentsOfFile: [NSString stringWithFormat:@"%@/Continents.plist", [[NSBundle mainBundle] resourcePath]]];
        _countryNames = [[NSDictionary alloc] initWithContentsOfFile: [NSString stringWithFormat:@"%@/Countries.plist", [[NSBundle mainBundle] resourcePath]]];
    }
    return self;
}

- (void) dealloc {
}

- (void) parse {
    // Job's done.
    if (_parsed)
        return;

    _continentCountries = [[NSMutableDictionary alloc] initWithCapacity:[_continentNames count]];
    _countryServers = [[NSMutableDictionary alloc] init];

    // Parse XML server list
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_serverListXML];
    [parser setDelegate:(id<NSXMLParserDelegate>)self];
    [parser parse];

    // Transform from NSDictionary representation to a NSArray-model
    NSArray *continentCodes = [[_continentNames allKeys] sortedArrayUsingSelector:@selector(compare:)];
    _modelContinents = [[NSMutableArray alloc] initWithCapacity:[continentCodes count]];
    _modelCountries = [[NSMutableArray alloc] init];

    for (NSString *key in continentCodes) {
        [_modelContinents addObject:[_continentNames objectForKey:key]];

        NSSet *countryCodeSet = [_continentCountries objectForKey:key];
        NSArray *countryCodes = [[countryCodeSet allObjects] sortedArrayUsingSelector:@selector(compare:)];

        NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];

        for (NSString *countryKey in countryCodes) {
            NSString *countryName = [_countryNames objectForKey:countryKey];
            NSArray *countryServerList = [_countryServers objectForKey:countryKey];
            NSDictionary *country = [NSDictionary dictionaryWithObjectsAndKeys:
                                        countryName, @"name",
                                        countryServerList, @"servers", nil];
            [countries addObject:country];
        }
        [_modelCountries addObject:countries];
    }

    _continentCountries = nil;
    _countryServers = nil;
    _parsed = YES;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"server"]) {
        NSString *countryCode = [attributeDict objectForKey:@"country_code"];
        if (countryCode) {
            // Get server array for this particular country
            NSMutableArray *array = [_countryServers objectForKey:countryCode];
            if (array == nil) {
                // No array available. Create a new one.
                array = [NSMutableArray arrayWithCapacity:50];
                [_countryServers setObject:array forKey:countryCode];
            }
            // Add attribute dict to server array.
            [array addObject:[attributeDict]];

            // Extract the continent code of the country
            NSString *continentCode = [attributeDict objectForKey:@"continent_code"];
            // Get our country set from our continent -> countries mapping
            NSMutableSet *countries = [_continentCountries objectForKey:continentCode];
            if (countries == nil) {
                // No set for continent? Create a new one.
                countries = [NSMutableSet setWithCapacity:100];
                [_continentCountries setObject:countries forKey:continentCode];
            }
            [countries addObject:countryCode];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

#pragma mark -
#pragma mark Model access

// Returns the number of continents in the public server list
- (NSInteger) numberOfContinents {
    return [_continentNames count];
}

// Get continent at index 'idx'.
- (NSString *) continentNameAtIndex:(NSInteger)index {
    return [_modelContinents objectAtIndex:index];
}

// Get the number of countries in the continent at index 'idx'.
- (NSInteger) numberOfCountriesAtContinentIndex:(NSInteger)index {
    return [[_modelCountries objectAtIndex:index] count];
}

// Get a dictionary representing a country.
- (NSDictionary *) countryAtIndexPath:(NSIndexPath *)indexPath {
    return [[_modelCountries objectAtIndex:[indexPath indexAtPosition:0]] objectAtIndex:[indexPath indexAtPosition:1]];
}

// Return whether or not the server list has already been parsed
- (BOOL) isParsed {
    return _parsed;
}

@end
