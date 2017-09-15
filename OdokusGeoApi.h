//
//  OdokusGeoApi.h
//  OGeoApi
//
//  Created by Johannes on 15.08.17.
//  Copyright © 2017 whileCoffee Software Development - Johannes Dürr. All rights reserved.
//
//
//             .__    .__.__         _________         _____  _____
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

@import CoreLocation;

#import <Foundation/Foundation.h>
#import "AFJSONRPCClient.h"

//#define useProgressHUD 1 // uncomment to use ProgressHUD
#ifdef useProgressHUD
#import "ProgressHUD.h" // (optional) import if using https://github.com/relatedcode/ProgressHUD
#endif

#define API_JSONRPC_URL @"https://developer.odokus.de/odokus2/json-rpc"
#define API_IMAGE_BASE_URL @"https://developer.odokus.de/odokus2"

@interface OdokusGeoApi : NSObject
{
    
    NSURL* baseURL;
    NSString* loginName;
    NSString* password;
    
    AFJSONRPCClient* client;
}

@property (nonnull) id delegate;

/**
 Initializing the object with a pointer to the delegate, username and password for your odokus account

 @param aDelegate : A OdokusGeoApiDelegate pointer
 @param userName : Odokus user name
 @param aPassword Odokus password
 @return api instance
 */
- (instancetype _Nonnull )initWithDelegate:(id _Nonnull )aDelegate andUserName:(NSString*_Nonnull)userName andPassword:(NSString*_Nonnull)aPassword;

// API methods
/**
 Simple API call to verify if connection to the odokus servers are possible and user credentials are correct.
 */
- (void)ping;

/**
 Call to retrieve GEO Events from odokus

 @param start : Starting date of the time span you will receive events for.
 @param end : Ending date of the time span you will receive events for.
 */
- (void)requestGeoEventsWithStart:(NSDate*_Nonnull)start andEnd:(NSDate*_Nonnull)end;

/**
 Call to add a new GEO Event to odokus

 @param date : The events date.
 @param typeString : Your Developer API App identifier.
 @param location : The events CLLocation.
 @param dictionary : A dictionary containing keys and values for that particular event.
 */
- (void)saveGeoEvent:(NSDate*_Nonnull)date typeString:(NSString*_Nonnull)typeString atLocation:(CLLocation*_Nonnull)location withExtensions:(NSDictionary*_Nonnull)dictionary;

@end

@protocol OdokusGeoApiDelegate <NSObject>

@required

- (void)odokusGeoApiDidFailWithError:(NSError*_Nonnull)err;

@optional

- (void)odokus_didReceivePing;
- (void)odokus_didReceiveGeoEvents:(id _Nullable )response;

@end
