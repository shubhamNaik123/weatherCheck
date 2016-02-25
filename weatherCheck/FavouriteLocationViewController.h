//
//  FavouriteLocationViewController.h
//  weatherCheck
//
//  Created by iMac2 on 04/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "coreData.h"

@interface FavouriteLocationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) coreData *model;
@property (weak, nonatomic) IBOutlet UITableView *tblFavouriteList;
@property (weak, nonatomic) IBOutlet UITextField *txtSearchLocation;
- (IBAction)btnCelecius:(id)sender;
- (IBAction)btnFahrenheit:(id)sender;
- (IBAction)btnSearchLocation:(id)sender;
- (IBAction)btnCancle:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *celeciusButton;
@property (weak, nonatomic) IBOutlet UIButton *fahrenheitButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *lblTemp;

@end
