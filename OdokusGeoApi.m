//
//  OdokusGeoApi.m
//  OGeoApi
//
//  Created by Johannes on 15.08.17.
//  Copyright © 2017 whileCoffee Software Development - Johannes Dürr. All rights reserved.
//
//
//
//     .__    .__.__         _________         _____  _____
//     __  _  _|  |__ |__|  |   ____ \_   ___ \  _____/ ____\/ ____\____   ____
//     \ \/ \/ /  |  \|  |  | _/ __ \/    \  \/ /  _ \   __\\   __\/ __ \_/ __ \
//      \     /|   Y  \  |  |_\  ___/\     \___(  <_> )  |   |  | \  ___/\  ___/
//       \/\_/ |___|  /__|____/\___  >\______  /\____/|__|   |__|  \___  >\___  >
//                  \/             \/        \/                        \/     \/
//     Released under MIT License for Hansenhof _electronic
//
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "OdokusGeoApi.h"

@implementation OdokusGeoApi

- (instancetype)init
{
    if (!self) {
        self = [super init];
    }
    return self;
}

- (instancetype)initWithDelegate:(id)aDelegate andUserName:(NSString*)userName andPassword:(NSString*)aPassword
{
    self = [self init];
    loginName = userName;
    password = aPassword;
    _delegate = aDelegate;
    baseURL = [NSURL URLWithString:API_JSONRPC_URL];
    
    client = [[AFJSONRPCClient alloc]initWithEndpointURL:baseURL usingAuthenticationLogin:loginName andPassword:password];
    
    return self;
}

- (void)ping
{
    [client invokeMethod:@"ping" withParameters:@[] requestId:@(0) success:^(NSURLSessionDataTask*operation, id responseObject) {
        // connection success
        [self pingResponseSuccess:responseObject];
    }   failure:^(NSURLSessionDataTask *operation, NSError *error) {
        // connection failed
        [self afJSONResponseWithError:error];
    }];
    
}

- (void)saveGeoEvent:(NSDate*)date typeString:(NSString*)typeString atLocation:(CLLocation*)location withExtensions:(NSDictionary*)dictionary
{
    
    // date
    NSDateFormatter* odokusDateFormatter = [[NSDateFormatter alloc]init];
    [odokusDateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'.000+0000'"];
    // requesting with date from odokus -- needs to change timezone!
    // date is iphone date -> switch to UTC
    [odokusDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString* dateString = [odokusDateFormatter stringFromDate:[NSDate date]];
    
    // Parameters for the API call
    NSArray* params;
    params = @[@{
                   @"type": typeString,
                   @"date": dateString,
                   @"longitude": @(location.coordinate.longitude),
                   @"latitude": @(location.coordinate.latitude),
                   @"extensions": dictionary
                   }];
    NSNumber *keyNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    
    [client invokeMethod:@"saveGeoEvent" withParameters:params
               requestId:keyNumber
                 success:^(NSURLSessionDataTask *operation, id responseObject) {
                     // connection success
#ifdef useProgressHUD
                     [ProgressHUD showSuccess];
#endif
                 }
                 failure:^(NSURLSessionDataTask *operation, NSError *error) {
                     // connection failed
                     [self afJSONResponseWithError:error];
                 }];
}

- (void)requestGeoEventsWithStart:(NSDate*)start andEnd:(NSDate*)end
{
    NSNumber *keyNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    NSString* startDateString = [self getOdokusDateStringFromNSDate:start];
    NSString* endDateString = [self getOdokusDateStringFromNSDate:end];
    NSArray* params =@[@{
                           @"startDate":startDateString,
                           @"endDate":endDateString
                        }];
    [client invokeMethod:@"getGeoEvents" withParameters:params
               requestId:keyNumber
                 success:^(NSURLSessionDataTask *operation, id responseObject) {
                     // connection success
#ifdef useProgressHUD
                     [ProgressHUD showSuccess];
#endif
                     [self getGeoEventsSuccess:responseObject];
                 }
                 failure:^(NSURLSessionDataTask *operation, NSError *error) {
                     // connection failed
                     [self afJSONResponseWithError:error];
                 }];

}

#pragma mark - server response handling

- (void)pingResponseSuccess:(id)responseObject
{
#ifdef useProgressHUD
    [ProgressHUD dismiss];
#endif
    NSLog(@"Got ping response...");
    if (_delegate != nil && [_delegate respondsToSelector:@selector(odokusGeoApiDidFailWithError:)]) {
        [_delegate odokus_didReceivePing];
    }
}

- (void)getGeoEventsSuccess:(id)responseObject
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(odokus_didReceiveGeoEvents:)]) {
        [_delegate odokus_didReceiveGeoEvents:responseObject];
    }
}

#pragma mark - Response failed for request to API

// Response for failed Request
- (void)afJSONResponseWithError:(NSError*)error{
    NSLog(@"A call to Odokus Service did fail:\n%@", [error description]);
#ifdef useProgressHUD
    [ProgressHUD showError:error.localizedDescription];
#endif
    if (_delegate != nil && [_delegate respondsToSelector:@selector(odokusGeoApiDidFailWithError:)]) {
        [_delegate odokusGeoApiDidFailWithError:error];
    }
}

- (void)afJSONResponseWithError_Silent:(NSError*)error{
    NSLog(@"A call to Odokus Service did fail:\n%@", [error description]);
    if (_delegate != nil && [_delegate respondsToSelector:@selector(odokusGeoApiDidFailWithError:)]) {
        [_delegate odokusGeoApiDidFailWithError:error];
    }
}

#pragma mark - Helper Functions

- (NSDate*)getNSDateFromOdokusDateString:(NSString*)dateString{
    NSDateFormatter* odokusDateFormatter = [[NSDateFormatter alloc]init];
    [odokusDateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'.000+0000'"];
    // Dates from Odokus are UTC - change from local timezone
    [odokusDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    if ([dateString hasSuffix:@"Z"]) {
        dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"+0000"];
    }
    NSDate* date = [odokusDateFormatter dateFromString:dateString];
    return date;
}

- (NSString*)getOdokusDateStringFromNSDate:(NSDate*)date{
    NSDateFormatter* odokusDateFormatter = [[NSDateFormatter alloc]init];
    [odokusDateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'.000+0000'"];
    // Dates from Odokus are UTC - change to local timezone.
    [odokusDateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString* dateString = [odokusDateFormatter stringFromDate:date];
    return dateString;
}


@end
