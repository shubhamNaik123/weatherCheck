//
//  coreData.m
//  weatherCheck
//
//  Created by iMac2 on 08/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import "coreData.h"

@implementation coreData

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(NSNumber *)addToFavourites: (NSString *)locationName latitude: (NSString *)latitude longitude: (NSString *)longitude condition: (NSString *)condition tempcelsius: (NSString *)tempcelsius tempfahrenheit: (NSString *)tempfahrenheit forecastDetails: (NSMutableArray *)forecastDetails icon:(NSString *) icon
{
    int value = [self fetchFavouriteData:latitude newLongitude:longitude];
    if(value == 0){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        [newLocation setValue:locationName forKey:@"locationName"];
        [newLocation setValue:latitude forKey:@"latitude"];
        [newLocation setValue:longitude forKey:@"longitude"];
        [newLocation setValue:condition forKey:@"condition"];
        [newLocation setValue:tempcelsius forKey:@"temp_c"];
        [newLocation setValue:tempfahrenheit forKey:@"temp_f"];
        [newLocation setValue:icon forKey:@"icon"];
        int rand = arc4random()%100;
        NSNumber *locationIDVal = [[NSNumber alloc]initWithInt:rand];
        [newLocation setValue:locationIDVal forKey:@"locationID"];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self addToForecast:forecastDetails locationID:locationIDVal];
        return locationIDVal;
    }
    return 0;
}


-(void)addToForecast: (NSMutableArray *)forecastDetails locationID: (NSNumber *) locationID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newforecastData;
    
    for (int i = 0; i< [forecastDetails count]; i++) {
       newforecastData= [NSEntityDescription insertNewObjectForEntityForName:@"Forecast" inManagedObjectContext:context];
        [newforecastData setValue:locationID forKey:@"locationID"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"avehumidity"] forKey:@"avgHumidity"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"conditions"] forKey:@"condition"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"day"] forKey:@"day"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"icon"] forKey:@"icon"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"temp_c"] forKey:@"temp_c"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"temp_f"] forKey:@"temp_f"];
        [newforecastData setValue:[forecastDetails[i] valueForKey:@"todaysDay"] forKey:@"weekday"];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}
-(int) fetchFavouriteData: (NSString *)newLatitude newLongitude: (NSString *)newLongitude
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Location"];
    request.returnsObjectsAsFaults = false;
    NSArray *fetchedData = [context executeFetchRequest:request error:nil];
    if ([fetchedData count] > 0) {
        NSArray *latitude = [fetchedData valueForKey:@"latitude"];
        NSArray *longitude = [fetchedData valueForKey:@"longitude"];
        
        for (int i=0; i< [latitude count]; i++) {
            if([latitude[i] isEqualToString:newLatitude] && [longitude[i] isEqualToString:newLongitude])
                return 1;
        }
        
    }
    return 0;
}

-(NSMutableArray *) fetchFavouriteList
{
    NSMutableArray *favouriteList = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Location"];
    request.returnsObjectsAsFaults = false;
    NSArray *fecthedData = [context executeFetchRequest:request error:nil];
    if ([fecthedData count]>0) {
        for (int i=0; i<[fecthedData count]; i++) {
            NSArray *temp = [[NSArray alloc]initWithObjects:
            @{@"LocationID" : [fecthedData[i] valueForKey:@"locationID"],
              @"locationName" : [fecthedData[i] valueForKey:@"locationName"],
              @"condition" : [fecthedData[i] valueForKey:@"condition"] ,
              @"temp_c" : [fecthedData[i] valueForKey:@"temp_c"],
              @"temp_f" : [fecthedData[i] valueForKey:@"temp_f"],
              @"latitude" : [fecthedData[i] valueForKey:@"latitude"],
              @"longitude" : [fecthedData[i] valueForKey:@"longitude"],
              @"icon" : [fecthedData[i] valueForKey:@"icon"]},nil];
            [favouriteList addObjectsFromArray:temp];
        }
    }
   return favouriteList;
}

-(NSMutableArray *) fetchForecatData: (NSString *) locationID
{
    NSMutableArray *forecastList = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Forecast"];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"locationID == %@", locationID];
    [request setPredicate:p];
    NSArray *fecthedData = [context executeFetchRequest:request error:nil];
    if ([fecthedData count]>0) {
        for (int i=0; i<[fecthedData count]; i++) {
               NSArray *temp = [[NSArray alloc]initWithObjects:
                                 @{@"avehumidity" : [NSString stringWithFormat:@"%@", [fecthedData[i] valueForKey:@"avgHumidity"] ],
                                   @"conditions" : [fecthedData[i] valueForKey:@"condition"] ,
                                   @"day" : [fecthedData[i] valueForKey:@"day"],
                                   @"icon" : [fecthedData[i] valueForKey:@"icon"],
                                   @"temp_c" : [fecthedData[i] valueForKey:@"temp_c"],
                                   @"temp_f" : [fecthedData[i] valueForKey:@"temp_f"],
                                   @"todaysDay" : [fecthedData[i] valueForKey:@"weekday"]}, nil];
                [forecastList addObjectsFromArray:temp];
            
           
        }
    }
    return forecastList;
}


-(NSString *) fetchLocationName: (NSString *)locationID
{
    NSString *locationName;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Location"];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"locationID == %@", locationID];
    [request setPredicate:p];
    NSArray *fecthedData = [context executeFetchRequest:request error:nil];
    if ([fecthedData count]>0) {
        locationName =[fecthedData[0] valueForKey:@"locationName"];
    }
    return locationName;
}
-(void) deleteFavouriteLocation:(NSString *)LocationID
{
    NSManagedObjectContext *context =[self managedObjectContext];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] initWithEntityName:@"Location"];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"locationID == %@", LocationID];
    [fetch setPredicate:p];
    NSError *fetchError;
    NSError *error;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    for (NSManagedObject *product in fetchedProducts) {
        [context deleteObject:product];
    }
    [context save:&error];
    [self deleteForecastData:LocationID];
}

-(void) deleteForecastData: (NSString *)locationID
{
    NSManagedObjectContext *context =[self managedObjectContext];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] initWithEntityName:@"Forecast"];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"locationID == %@", locationID];
    [fetch setPredicate:p];
    NSError *fetchError;
    NSError *error;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    for (NSManagedObject *product in fetchedProducts) {
        [context deleteObject:product];
    }
    [context save:&error];
   
}
-(void) updateFavouriteList: (NSString *)locationID temp_c: (NSString *)temp_c temp_f: (NSString *)temp_f condition: (NSString *)condition icon: (NSString *)icon
{
    NSManagedObjectContext *context =[self managedObjectContext];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] initWithEntityName:@"Location"];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"locationID == %@", locationID];
    [fetch setPredicate:p];
    NSError *fetchError;
    NSArray *fetchedData=[context executeFetchRequest:fetch error:&fetchError];
    NSManagedObject* locationDetails = [fetchedData objectAtIndex:0];
    [locationDetails setValue:condition forKey:@"condition"];
    [locationDetails setValue:temp_c forKey:@"temp_c"];
    [locationDetails setValue:temp_f forKey:@"temp_f"];
    [locationDetails setValue:icon forKey:@"icon"];

}

- (BOOL)checkForNetwork
{
     BOOL networkStatus = 0;
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            networkStatus = 0;
            break;
            
        case ReachableViaWWAN:
            networkStatus = 1;
            break;
            
        case ReachableViaWiFi:
            networkStatus = 1;
            break;
            
        default:
            break;
    }
    [myNetwork startNotifier];

    return networkStatus;
}

@end
