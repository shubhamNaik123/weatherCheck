//
//  TodayViewController.m
//  Weather widget
//
//  Created by iMac2 on 02/03/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.preferredContentSize = CGSizeMake(0, 86);
     [self updateTempData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateTempData];
}

- (void)updateTempData {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.sjiinovation.phonegap.weatherCheck"];
    NSString *location = [defaults stringForKey:@"location"];
    NSString *conditions = [defaults stringForKey:@"conditions"];
    NSString *temp = [defaults stringForKey:@"temp"];
    NSString *avehumidity = [defaults stringForKey:@"avehumidity"];
    NSString *imageIcon = [defaults stringForKey:@"image"];
    self.lblPlace.text = location;
    self.lblCondition.text = conditions;
    self.lbltemp.text = temp;
    self.lblHumidity.text = [@"Humidity: " stringByAppendingString: avehumidity];
    
    CommonCode *test = [[CommonCode alloc]init];
   self.weatherImg.image = [UIImage imageNamed: [test displayIcon:imageIcon]];
}

@end
