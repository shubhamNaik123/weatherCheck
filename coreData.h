//
//  coreData.h
//  weatherCheck
//
//  Created by iMac2 on 08/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Reachability.h"

@interface coreData : NSManagedObject
-(NSMutableArray *) fetchFavouriteList;
-(void) deleteFavouriteLocation:(NSString *)LocationID;
-(NSString *) fetchLocationName: (NSString *)locationID;
-(int) fetchFavouriteData: (NSString *)newLatitude
             newLongitude: (NSString *)newLongitude;
-(NSNumber *)addToFavourites: (NSString *)locationName
              latitude: (NSString *)latitude
             longitude: (NSString *)longitude
             condition: (NSString *)condition
           tempcelsius: (NSString *)tempcelsius
        tempfahrenheit: (NSString *)tempfahrenheit
       forecastDetails: (NSMutableArray *)forecastDetails
                    icon:(NSString *) icon;
-(void) updateFavouriteList: (NSString *)locationID
                     temp_c: (NSString *)temp_c
                     temp_f: (NSString *)temp_f
                  condition: (NSString *)condition
                       icon: (NSString *)icon;
-(NSMutableArray *) fetchForecatData: (NSString *) locationID;
- (BOOL)checkForNetwork;
@end
