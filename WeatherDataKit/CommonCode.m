//
//  CommonCode.m
//  weatherCheck
//
//  Created by iMac2 on 03/03/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import "CommonCode.h"

@implementation CommonCode


-(NSString *) displayIcon: (NSString *)icon
{
    icon = [icon lowercaseString];
    if([icon containsString:@"flurries"] || [icon containsString:@"snow"])
        icon=@"flurries";
    else if([icon isEqualToString:@"clear"] || [icon isEqualToString:@"sunny"])
        icon=@"clear";
    else if([icon containsString:@"clear"] || [icon containsString:@"sunny"])
        icon=@"clear";
    else if([icon isEqualToString:@"cloudy"] || [icon isEqualToString:@"cloudy-1"])
        icon=@"cloudy";
    else if([icon containsString:@"fog"] || [icon containsString:@"hazy"])
        icon=@"fog";
    else if([icon containsString:@"cloudy"] || [icon containsString:@"partlycloudy"] || [icon containsString:@"partlysunny"])
        icon=@"mostlycloudy";
    else if([icon containsString:@"rain"])
        icon=@"rain";
    else if([icon containsString:@"sleet"])
        icon=@"sleet";
    else if([icon containsString:@"storms"])
        icon=@"storms";
    return icon;
}
@end
