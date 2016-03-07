//
//  FavouriteLocationViewController.m
//  weatherCheck
//
//  Created by iMac2 on 04/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import "FavouriteLocationViewController.h"

@interface FavouriteLocationViewController ()

@end

@implementation FavouriteLocationViewController
{
    NSMutableArray *favouriteList, *locationLatitude, *locationLongitude;
    BOOL settingValue;
    int value,pageCounterValue;
}

-(coreData *) model
{
    if(!_model)
    {
        _model = [[coreData alloc]init];
    }
    return _model;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblFavouriteList.dataSource = self;
    self.tblFavouriteList.delegate = self;
    self.txtSearchLocation.hidden = true;
    self.cancleButton.hidden = true;
    value = 0;
    [self.txtSearchLocation addTarget:self action:@selector(textFieldDidChage:) forControlEvents:UIControlEventEditingChanged];
    BOOL connected = [self.model checkForNetwork];
    if(connected == 0)
    {
        favouriteList = [self.model fetchFavouriteList];
    }
    else
    {
        BOOL dateValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"sameData"];
        if(dateValue){
            favouriteList = [self.model fetchFavouriteList];
        }
        else
        {
             [self updateFavouriteList];
        }
    }
    if ([favouriteList count] >= 5) {
        self.addButton.hidden = YES;
    }
    pageCounterValue = (int)[favouriteList count];
 }

-(void) displayAlert: (NSString *)msg
{
    UIAlertView *displayAlert = [[UIAlertView alloc] initWithTitle:@"Weather App" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [displayAlert show];
}

-(NSMutableArray *) updateFavouriteList
{
    NSMutableArray *updatedList = [[NSMutableArray alloc]init];
    NSArray *tempList = [self.model fetchFavouriteList];
    for (int i =0; i< [tempList count]; i++)
    {
      NSArray *temp = [[NSArray alloc]initWithObjects:@{@"latitude": [tempList[i] valueForKey:@"latitude"],@"longitude": [tempList[i] valueForKey:@"longitude"]}, nil];
      [updatedList addObjectsFromArray:temp];
      [self weatherChange:[tempList[i] valueForKey:@"latitude"] longitude:[tempList[i] valueForKey:@"longitude"] locationId:[tempList[i] valueForKey:@"LocationID"]];
    }
    favouriteList = [self.model fetchFavouriteList];
    return updatedList;
}

-(void) weatherChange: (NSString *)latitude longitude:(NSString *)longitude locationId: (NSString *)locationID
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/95d48985df985314/forecast10day/q/%@,%@.json",latitude,longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil) {
             @try {
                 NSDictionary *forecast10day = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                 NSArray *foreCast =[forecast10day objectForKey:@"forecast"];
                 NSArray *simpleforecast = [foreCast valueForKey:@"simpleforecast"];
                 NSArray *forecastday = [simpleforecast valueForKey: @"forecastday"];
                 NSArray *day0 = [forecastday objectAtIndex:0];
                 NSString *status =[day0 valueForKey:@"conditions"];
                 CGFloat currTempCelsius = [[[day0 valueForKey:@"high"] valueForKey:@"celsius"]doubleValue];
                 NSString *tempcelsius = [[NSString stringWithFormat:@"%.f", currTempCelsius] stringByAppendingString:@"°"];
                 CGFloat currTempfahrenheit = [[[day0 valueForKey:@"high"] valueForKey:@"fahrenheit"]doubleValue];
                 NSString *tempfahrenheit = [[NSString stringWithFormat:@"%.f", currTempfahrenheit] stringByAppendingString:@"°"];
                 NSString *icon = [day0 valueForKey:@"icon"];
                 [self.model updateFavouriteList:locationID temp_c:tempcelsius temp_f:tempfahrenheit condition:status icon:icon];
             }
             @catch (NSException *exception) {
                 NSLog(@"Error");
             }
             @finally {
              }
         }
         else
         {
             NSLog(@"Error");
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favouriteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    if(value == 0){
    cell.textLabel.text = [[favouriteList objectAtIndex:indexPath.row] valueForKey:@"locationName"];
    NSString *details;
    settingValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"settingValue"];
    if (settingValue == 0) {
        [self.fahrenheitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        details = [[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"temp_f"] stringByAppendingString: @", "];
    }
    else
    {
        [self.celeciusButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        details = [[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"temp_c"] stringByAppendingString: @", "];
    }
    details = [details stringByAppendingString:[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"condition"]];
    cell.detailTextLabel.text = details;
    NSString *cellImage = [self backgroundImage:[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"icon"]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:cellImage] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        self.tblFavouriteList.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        [tableView setSeparatorColor:[UIColor clearColor]];
        cell.layer.cornerRadius = 5;
        cell.layer.masksToBounds = YES;
        cell.layer.borderWidth = 3;
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
     }
    else if(value == 1){
     cell.textLabel.text = [favouriteList objectAtIndex:indexPath.row];
        
        cell.layer.cornerRadius = 9;
        cell.layer.masksToBounds = YES;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [UIColor grayColor].CGColor;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [self dismissViewControllerAnimated:YES completion:nil];
    ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"WeatherView"];
    
    if(value == 0){
    view.locationName=[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"locationName"];
    view.locationlatitude=[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"latitude"];
    view.locationlongitude=[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"longitude"];
    view.locationID = [[favouriteList objectAtIndex:indexPath.row] valueForKey:@"LocationID"];
    view.pageNumber = (int)indexPath.row;
    }
    else if (value == 1)
    {
        NSInteger rowNumber = indexPath.row;
        view.locationName=[favouriteList objectAtIndex:rowNumber];
        view.locationlatitude=[locationLatitude objectAtIndex:rowNumber];
        view.locationlongitude=[locationLongitude objectAtIndex:rowNumber];
        view.pageNumber = ++pageCounterValue;
    }
     [self.navigationController pushViewController:view animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.model deleteFavouriteLocation:[[favouriteList objectAtIndex:indexPath.row] valueForKey:@"LocationID" ]];
        [favouriteList removeObjectAtIndex:indexPath.row];
        [self.tblFavouriteList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if ([favouriteList count] < 5) {
            self.addButton.hidden = FALSE;
        }
    }
}

-(NSString *) backgroundImage: (NSString *) weatherStatus
{
    NSString *cellImage;
    weatherStatus = [weatherStatus lowercaseString];
    if([weatherStatus containsString:@"hazy"] || [weatherStatus containsString:@"cloudy"] || [weatherStatus containsString:@"fog"] || [weatherStatus containsString:@"mostly cloudy"] || [weatherStatus containsString:@"partly"])
        cellImage = @"hazyBackground";
    else if([weatherStatus containsString:@"clear"] || [weatherStatus containsString:@"sunny"])
        cellImage = @"clearBackground";
    else if([weatherStatus containsString:@"rain"] || [weatherStatus containsString:@"sleet"] || [weatherStatus containsString:@"storms"])
        cellImage = @"rainBackground";
    else if([weatherStatus containsString:@"snow"] || [weatherStatus containsString:@"flurries"])
        cellImage = @"snowyBackground";
    return cellImage;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    [view setAlpha:0.0F];
    return view;
}

- (IBAction)btnCelecius:(id)sender {
   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"settingValue"];
    [UIView animateWithDuration:0.5 animations:^{
      [self.celeciusButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.fahrenheitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }];
    [self.tblFavouriteList reloadData];
}

- (IBAction)btnFahrenheit:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"settingValue"];
    [UIView animateWithDuration:0.5 animations:^{
        [self.fahrenheitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.celeciusButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }];
    [self.tblFavouriteList reloadData];
}


- (IBAction)btnSearchLocation:(id)sender {
    value = 1;
    self.txtSearchLocation.hidden = false;
    self.cancleButton.hidden=false;
    self.celeciusButton.hidden = true;
    self.fahrenheitButton.hidden = true;
    self.addButton.hidden = true;
    self.lblTemp.hidden = true;
    [favouriteList removeAllObjects];
    [self.tblFavouriteList reloadData];

}

- (IBAction)btnCancle:(id)sender {
    value = 0;
    favouriteList = [self.model fetchFavouriteList];
    [self.tblFavouriteList reloadData];
    self.txtSearchLocation.hidden = true;
    self.cancleButton.hidden = true;
    self.celeciusButton.hidden = false;
    self.fahrenheitButton.hidden = false;
    self.addButton.hidden = false;
    self.lblTemp.hidden= false;
    self.txtSearchLocation.text = @"";
    favouriteList = [self.model fetchFavouriteList];
    [self.tblFavouriteList reloadData];
   
}

-(void)textFieldDidChage: (UITextField *)textField
{
    NSString *searchString = textField.text;
    [self locationSearchCall:searchString];
}

-(void) locationSearchCall: (NSString *)searchText
{
    NSString *urlString = [NSString stringWithFormat:@"http://autocomplete.wunderground.com/aq?query=%@",searchText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue ]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if(data.length > 0 && connectionError == nil)
         {
             favouriteList = [[NSMutableArray alloc]init];
             locationLatitude = [[NSMutableArray alloc]init];
             locationLongitude = [[NSMutableArray alloc]init];
             
             NSDictionary *Locations = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
             NSArray *results =[Locations objectForKey:@"RESULTS"];
             NSArray *locationName = [results valueForKey:@"name"];
             [favouriteList addObjectsFromArray:locationName];
             NSArray *latitude = [results valueForKey:@"lat"];
             [locationLatitude addObjectsFromArray:latitude];
             NSArray *longitude = [results valueForKey:@"lon"];
             [locationLongitude addObjectsFromArray:longitude];
             if([favouriteList count] > 0)
             {
                 self.tblFavouriteList.hidden = false;
                 [self.tblFavouriteList reloadData];
             }
             else
             {
               [self.tblFavouriteList reloadData];
                 
             }
         }
     }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (value == 0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txtSearchLocation endEditing:YES];
}

@end
