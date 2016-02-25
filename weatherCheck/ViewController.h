//
//  ViewController.h
//  weatherCheck
//
//  Created by iMac2 on 01/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FavouriteLocationViewController.h"
#import "coreData.h"
#import <Social/Social.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate,UICollectionViewDataSource>

@property (nonatomic, strong)coreData *model;
@property (weak, nonatomic) IBOutlet UILabel *txtSearchLocation;
@property (weak, nonatomic) IBOutlet UILabel *txtTemparature;
@property (weak, nonatomic) IBOutlet UILabel *txtWeatherStatus;
@property (weak, nonatomic) IBOutlet UITableView *tblWeekly;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon_url;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *locationlatitude;
@property (strong, nonatomic) NSString *locationlongitude;
@property (strong, nonatomic) NSString *locationID;
@property (assign, nonatomic) int pageNumber;
@property (weak, nonatomic) IBOutlet UICollectionView *hourlyCollectionView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;
- (IBAction)btnAppShare:(id)sender;
- (IBAction)btnFavourites:(id)sender;
- (IBAction)btnRefresh:(id)sender;

@end

