//
//  ViewController.m
//  weatherCheck
//
//  Created by iMac2 on 01/02/16.
//  Copyright © 2016 SJI. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *weatherDetailsArray, *hourlyForeCastArray, *favouriteList;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
     BOOL settingValue, connectedVal;
    int currPageNumber;
    NSString *fbMsg;
    NSUserDefaults *prefs;
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
    self.tblWeekly.dataSource = self;
    self.tblWeekly.delegate =self;
    self.tblWeekly.hidden = true;
    self.tblWeekly.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.hourlyCollectionView.hidden = true;
    self.hourlyCollectionView.dataSource = self;
    prefs = [NSUserDefaults standardUserDefaults];
    settingValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"settingValue"];
    NSString *currDate = [self todaysDate];
    NSString *dateValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"date"];

    if([dateValue length]==0)
    {
        [prefs setObject:currDate forKey:@"date"];
    }
    else
    {
        prefs = [NSUserDefaults standardUserDefaults];
        NSString *localDate = [prefs stringForKey:@"date"];
        if (![localDate isEqualToString:currDate]) {
           [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"sameData"];
        }
    }
    
    favouriteList = [self.model fetchFavouriteList];
    if ([favouriteList count] > 0) {
        self.pageControl.numberOfPages = [favouriteList count];
        [self swipeFunction];
    }
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor blackColor];
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    connectedVal = [self.model checkForNetwork];
   
    if(connectedVal == 0)
    {
        [self offlineMode];
    }
    else
    {
        [self connectionReachable];
    }
}

-(void) connectionReachable
{
    if (self.locationName.length > 0)
    {
       [self weatherForecast:self.locationlatitude longitude:self.locationlongitude location:self.locationName];
        currPageNumber = self.pageNumber;
        self.pageControl.currentPage = currPageNumber;
    }
    else
    {
        [self getGeoLocation];
    }
}

-(void)getGeoLocation
{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    currPageNumber = 0;
}

-(void) offlineMode
{
     NSString *locationID;
    if ([favouriteList count] > 0) {
        [self displayAlert:@"Please check your network connection! Currently displaying saved data."];
        if (self.locationName.length > 0)
        {
            locationID = self.locationID;
            [prefs setObject:locationID forKey:@"locationID"];
            currPageNumber = self.pageNumber;
            self.pageControl.currentPage = currPageNumber;
        }
        else
        {
            locationID = [prefs stringForKey:@"locationID"];
           self.locationName = [self.model fetchLocationName:locationID];
            
        }
        weatherDetailsArray = [self.model fetchForecatData:locationID];
        if([weatherDetailsArray count] == 0)
        {
           
            weatherDetailsArray = [self.model fetchForecatData:[[favouriteList objectAtIndex:0] valueForKey:@"LocationID"]];
            self.locationName = [[favouriteList objectAtIndex:0] valueForKey:@"locationName"];
        }
        [self UIDataDisplay:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"latitude"] longitude:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"longitude"] location:self.locationName connected:0];
        self.tblWeekly.hidden = false;
        [self.tblWeekly reloadData];
    }
    else{
        [self displayAlert:@"Please check your network connection!"];
        [self.activityIndicatorView stopAnimating];
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


-(NSString *) todaysDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateValue =[formatter stringFromDate:[NSDate date]];
    return dateValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
   __block NSString *address;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
    if(error == nil && [placemarks count]>0)
    {
        placemark = [placemarks lastObject];
        address = [NSString stringWithFormat:@"%@, %@",
                   placemark.locality,
                   placemark.country];
    }
        if(![address isEqualToString:@""])
        [self weatherForecast:[NSString stringWithFormat:@"%.4f", currentLocation.coordinate.latitude] longitude:[NSString stringWithFormat:@"%.4f", currentLocation.coordinate.longitude] location:address];
    }];
   [locationManager stopUpdatingLocation];
}

-(void) weatherForecast: (NSString *)latitude longitude:(NSString *)longitude location:(NSString *)location
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
             self.tblWeekly.hidden = false;
             @try {
                 NSDictionary *forecast10day = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                 NSArray *foreCast =[forecast10day objectForKey:@"forecast"];
                 NSArray *simpleforecast = [foreCast valueForKey:@"simpleforecast"];
                 NSArray *forecastday = [simpleforecast valueForKey: @"forecastday"];
                 NSString *temparatureVar = @"high";
                 if ([[[forecastday[0] valueForKey:@"high"] valueForKey:@"celsius"] isEqualToString:@""]) {
                    temparatureVar = @"low";
                 }
                 weatherDetailsArray = [[NSMutableArray alloc]init];
                 for (int i =0; i<[forecastday count]; i++) {
                     NSArray *temp = [[NSArray alloc]initWithObjects:@{@"todaysDay" : [[forecastday[i] valueForKey:@"date"] valueForKey:@"weekday"],@"day" : [[forecastday[i] valueForKey:@"date"] valueForKey:@"day"],@"conditions" : [forecastday[i] valueForKey:@"conditions"], @"icon" : [forecastday[i] valueForKey:@"icon"],@"avehumidity" : [forecastday[i] valueForKey:@"avehumidity"] ,@"temp_c" : [[forecastday[i] valueForKey:temparatureVar] valueForKey:@"celsius"],@"temp_f" : [[forecastday[i] valueForKey:temparatureVar] valueForKey:@"fahrenheit"]}, nil];
                     [weatherDetailsArray addObjectsFromArray:temp];
                     
                 }
                 [self hourlyForecast:latitude longitude:longitude];
                 [self UIDataDisplay:latitude longitude:longitude location:location connected:1];
                
             }
             @catch (NSException *exception) {
                [self displayAlert:@"Key is not valid due to exceeding rate plan. Visit \"http://www.wunderground.com\" to renew your plan."];
                 self.pageControl.hidden = true;
                 self.tblWeekly.hidden = true;
             }
             @finally {
                  [self.tblWeekly reloadData];
             }
         }
         else
         {
             NSLog(@"Error");
         }
     }];
}

-(void) UIDataDisplay: (NSString *)latitude longitude:(NSString *)longitude location:(NSString *)location connected: (BOOL) connected
{
    self.locationlatitude = latitude;
    self.locationlongitude = longitude;
    [prefs setObject:location forKey:@"locationName"];
    self.locationName = location;
    NSArray *day0 = [weatherDetailsArray objectAtIndex:0];
    self.txtSearchLocation.text = location;
    NSString *status =[day0 valueForKey:@"conditions"];
    self.txtWeatherStatus.text =status;
    CGFloat currTempfahrenheit = [[day0 valueForKey:@"temp_f"]doubleValue];
    NSString *tempfahrenheit = [[NSString stringWithFormat:@"%.f", currTempfahrenheit] stringByAppendingString:@"°"];
    CGFloat currTempCelsius = [[day0  valueForKey:@"temp_c"]doubleValue];
    NSString *tempcelsius = [[NSString stringWithFormat:@"%.f", currTempCelsius] stringByAppendingString:@"°"];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.sjiinovation.phonegap.weatherCheck"];
    CGFloat avehumidity = [[day0 valueForKey:@"avehumidity"]doubleValue];
    [sharedDefaults setValue:[[NSString stringWithFormat:@"%.f", avehumidity]stringByAppendingString:@"%"] forKey:@"avehumidity"];
    [sharedDefaults setValue:location forKey:@"location"];
    [sharedDefaults setValue:status forKey:@"conditions"];
    [sharedDefaults setValue:[day0 valueForKey:@"icon"] forKey:@"image"];
    CommonCode *imageFunction = [[CommonCode alloc]init];
    self.imgIcon_url.image = [UIImage imageNamed: [imageFunction displayIcon:[day0 valueForKey:@"icon"]]];
    [self backgroundImage:[day0 valueForKey:@"icon"]];

    if (settingValue == 0) {
        self.txtTemparature.text = tempfahrenheit;
        [sharedDefaults setValue:tempfahrenheit forKey:@"temp"];
    }
    else
    {
        self.txtTemparature.text = tempcelsius;
        [sharedDefaults setValue:tempcelsius forKey:@"temp"];
    }
    [sharedDefaults synchronize];
       if (connected == 1) {
        if (![status isEqualToString:@"nil"] &&( ![tempcelsius isEqualToString:@"0°"] || ![tempfahrenheit isEqualToString:@"0°"])) {
            NSNumber * locationID =  [self.model addToFavourites:location latitude:latitude longitude:longitude condition:status tempcelsius:tempcelsius tempfahrenheit:tempfahrenheit forecastDetails: weatherDetailsArray icon:[day0 valueForKey:@"icon"]];
            if(locationID > 0){
                [prefs setObject:locationID forKey:@"locationID"];
                int pageCounter = (int)[favouriteList count];
                self.pageControl.numberOfPages =++pageCounter;
                [favouriteList removeAllObjects];
                 favouriteList = [self.model fetchFavouriteList];
            }
            else if(self.locationID > 0){
            [prefs setObject:self.locationID forKey:@"locationID"];
            }
        }
    }
    else{
        [self.activityIndicatorView stopAnimating];
    }
    [self foreCastMessage:location temp:tempcelsius condition:status];
}

-(void) backgroundImage: (NSString *) weatherStatus
{
    weatherStatus = [weatherStatus lowercaseString];
    if([weatherStatus containsString:@"hazy"] || [weatherStatus containsString:@"cloudy"] || [weatherStatus containsString:@"fog"] || [weatherStatus containsString:@"mostly cloudy"] || [weatherStatus containsString:@"partly"])
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hazyBackground"]];
    else if([weatherStatus containsString:@"clear"] || [weatherStatus containsString:@"sunny"])
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"clearBackground"]];
    else if([weatherStatus containsString:@"rain"] || [weatherStatus containsString:@"sleet"] || [weatherStatus containsString:@"storms"])
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rainBackground"]];
    else if([weatherStatus containsString:@"snow"] || [weatherStatus containsString:@"flurries"])
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"snowyBackground"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [weatherDetailsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *contentTitle = (UILabel *)[cell viewWithTag:101];
    contentTitle.text = [[weatherDetailsArray objectAtIndex:indexPath.row] valueForKey:@"todaysDay"];
    
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:102];
    contentImage.image = [UIImage imageNamed:[self displayIcon:[[weatherDetailsArray objectAtIndex:indexPath.row] valueForKey:@"icon"]]];

    CGFloat currHumidity = [[[weatherDetailsArray objectAtIndex:indexPath.row] valueForKey:@"avehumidity"]doubleValue];

    UILabel *humidity = (UILabel *)[cell viewWithTag:103];
    humidity.text = [[NSString stringWithFormat:@"%.f", currHumidity]stringByAppendingString:@"%"];
    
    UILabel *temp = (UILabel *)[cell viewWithTag:104];
     if (settingValue == 0) {
        CGFloat currTemp = [[[weatherDetailsArray objectAtIndex:indexPath.row] valueForKey:@"temp_f"]doubleValue];
        temp.text = [[NSString stringWithFormat:@"%.f", currTemp] stringByAppendingString:@"°"];
    }
    else
    {
        CGFloat currTemp = [[[weatherDetailsArray objectAtIndex:indexPath.row] valueForKey:@"temp_c"]doubleValue];
        temp.text = [[NSString stringWithFormat:@"%.f", currTemp] stringByAppendingString:@"°"];
    }

    [self.tblWeekly setBackgroundColor:[UIColor clearColor]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

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

-(void) displayAlert: (NSString *)msg
{
   UIAlertView *displayAlert = [[UIAlertView alloc] initWithTitle:@"Weather App" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [displayAlert show];
}

- (IBAction)btnAppShare:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:fbMsg];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (IBAction)btnFavourites:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    FavouriteLocationViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Favourite"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)btnRefresh:(id)sender {
        connectedVal = [self.model checkForNetwork];
        if(connectedVal == 1)
        {
            [self.activityIndicatorView startAnimating];
            [self connectionReachable];
        }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [hourlyForeCastArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *contentTitle = (UILabel *)[cell viewWithTag:101];
     if (settingValue == 0) {
         contentTitle.text = [NSString stringWithFormat:@"%@:00 %@°",[[hourlyForeCastArray objectAtIndex:indexPath.row]valueForKey:@"hour"], [[hourlyForeCastArray objectAtIndex:indexPath.row]valueForKey:@"temp_f"]];
     }
    else
    {
         contentTitle.text = [NSString stringWithFormat:@"%@:00 %@°",[[hourlyForeCastArray objectAtIndex:indexPath.row]valueForKey:@"hour"], [[hourlyForeCastArray objectAtIndex:indexPath.row]valueForKey:@"temp_c"]];
    }
    UIImageView *contentImage = (UIImageView *)[cell viewWithTag:102];
    contentImage.image = [UIImage imageNamed:[self displayIcon:[[hourlyForeCastArray objectAtIndex:indexPath.row] valueForKey:@"icon"]]];

    [self.hourlyCollectionView setBackgroundColor:[UIColor clearColor]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void) hourlyForecast :(NSString *)latitude longitude: (NSString *)longitude
{
    hourlyForeCastArray = [[NSMutableArray alloc]init];
    NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/95d48985df985314/hourly/q/%@,%@.json",latitude,longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
      [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil) {
           
             @try {
                
                 NSDictionary *forecast10day = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                 NSArray *hourly_forecast =[forecast10day objectForKey:@"hourly_forecast"];
                 NSArray *FCTTIME = [hourly_forecast valueForKey:@"FCTTIME"];
                  for (int i= 0; i< [FCTTIME count]; i++) {
                     if ([[FCTTIME[i] valueForKey:@"hour"] isEqualToString:@"0"] || [[FCTTIME[i] valueForKey:@"hour"] isEqualToString:@"3"] || [[FCTTIME[i] valueForKey:@"hour"] isEqualToString:@"6"] || [[FCTTIME[i] valueForKey:@"hour"] isEqualToString:@"9"] || [[FCTTIME[i] valueForKey:@"hour"] containsString:@"12"] ||[[FCTTIME[i] valueForKey:@"hour"] containsString:@"15"] || [[FCTTIME[i] valueForKey:@"hour"] containsString:@"18"] || [[FCTTIME[i] valueForKey:@"hour"] containsString:@"21"])
                     {
                         NSArray *temp = [[NSArray alloc]initWithObjects:@{@"hour" : [FCTTIME[i] valueForKey:@"hour"],@"day" : [FCTTIME[i] valueForKey:@"mday"],@"icon" : [hourly_forecast[i] valueForKey:@"icon"], @"temp_f" : [[hourly_forecast[i] valueForKey:@"temp"] valueForKey:@"english"],@"temp_c" : [[hourly_forecast[i] valueForKey:@"temp"] valueForKey:@"metric"]}, nil];
                         [hourlyForeCastArray addObjectsFromArray:temp];
                     }
                 }
                 if ([hourlyForeCastArray count] > 0) {
                      self.hourlyCollectionView.hidden = false;
                 }
             }
             @catch (NSException *exception) {
                 [self displayAlert:@"Key is not valid due to exceeding rate plan. Visit \"http://www.wunderground.com\" to renew your plan."];
             }
             @finally {
                 [self.hourlyCollectionView reloadData];
                 [self.activityIndicatorView stopAnimating];
             }
         }
         else
         {
             NSLog(@"Error");
         }
     }];
   

}

-(void) swipeFunction
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    connectedVal = [self.model checkForNetwork];
    if(swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        int nextPageNum = currPageNumber;
        
        if(++nextPageNum<[favouriteList count]){
             [self.activityIndicatorView startAnimating];
            currPageNumber++;
            if(connectedVal == 0)
            {
                [self displayAlert:@"Please check your network connection! Currently displaying saved data."];
                [weatherDetailsArray removeAllObjects];
                 self.hourlyCollectionView.hidden = true;
                 weatherDetailsArray = [self.model fetchForecatData:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"LocationID"]];
                if([weatherDetailsArray count] > 0)
                {
                    [self UIDataDisplay:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"latitude"] longitude:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"longitude"] location:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"locationName"] connected:0];
                    self.tblWeekly.hidden = false;
                    [self.tblWeekly reloadData];
                }
            }
            else{
         [self weatherForecast:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"latitude"] longitude:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"longitude"] location:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"locationName"]];
           
            }
             [prefs setObject:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"LocationID"] forKey:@"locationID"];
             self.pageControl.currentPage = currPageNumber;
        }
      
    }
    
    if(swipe.direction == UISwipeGestureRecognizerDirectionRight) {
       
        if(currPageNumber > 0){
             [self.activityIndicatorView startAnimating];
             currPageNumber--;
            if(connectedVal == 0)
            {
                [self displayAlert:@"Please check your network connection! Currently displaying saved data."];
                [weatherDetailsArray removeAllObjects];
                self.hourlyCollectionView.hidden = true;
                weatherDetailsArray = [self.model fetchForecatData:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"LocationID"]];
                if([weatherDetailsArray count] > 0)
                {
                    [self UIDataDisplay:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"latitude"] longitude:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"longitude"] location:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"locationName"] connected:0];
                    self.tblWeekly.hidden = false;
                    [self.tblWeekly reloadData];
                }
            }
            else{
                [self weatherForecast:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"latitude"] longitude:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"longitude"] location:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"locationName"]];
                
            }
            [prefs setObject:[[favouriteList objectAtIndex:currPageNumber] valueForKey:@"LocationID"] forKey:@"locationID"];
            self.pageControl.currentPage = currPageNumber;

        }
        
    }
}

-(void)foreCastMessage: (NSString *)location temp:(NSString *)temp condition: (NSString *)condition
{
    fbMsg = [NSString stringWithFormat:@"Today's Forecast\nLocation: %@ \nTemparature °C: %@ \n Condition: %@", location, temp, condition];
}

@end
