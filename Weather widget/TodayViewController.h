//
//  TodayViewController.h
//  Weather widget
//
//  Created by iMac2 on 02/03/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherDataKit.h"
@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *weatherImg;
@property (weak, nonatomic) IBOutlet UILabel *lblCondition;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lbltemp;
@property (weak, nonatomic) IBOutlet UILabel *lblPlace;

@end
