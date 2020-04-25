//
//  FirstViewController.m
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-14.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import "RadarController.h"
#import "RadarModel.h"
#import <CoreLocation/CoreLocation.h>

@interface RadarController ()

@end

@implementation RadarController

CLLocationManager *locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    if (!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    // Create scroll container and add it to the scroll view
    self.scrollContainer = [[UIView alloc] init];
    self.scrollContainer.frame = CGRectMake(0.0, 0.0, 200.0, 200.0);
    [self.scrollView addSubview:self.scrollContainer];
    
    // Create image view and add it to scroll view
    self.imageView = [[UIImageView alloc] init];
    [self.scrollContainer addSubview:self.imageView];
    
    // Create location marker uiimage
    self.locationMarker = [[UIImageView alloc] init];
    self.locationMarker.image = [UIImage imageNamed:@"location_marker.png"];
    [self.locationMarker setContentMode:UIViewContentModeScaleAspectFit];
    self.locationMarker.frame = CGRectMake(0.0, 0.0, self.locationMarker.image.size.width, self.locationMarker.image.size.height);
    self.locationMarker.center = CGPointMake(100, 200);
    //self.locationMarker.backgroundColor = [UIColor greenColor];
    [self.scrollContainer addSubview:self.locationMarker];
    
    //NSString *path = @"http://emh.ottawaengineers.ca/radar_sample.gif";
    //NSString *path = [RadarModel buildRadarURLWithStation:@"XFT" andDate:[RadarModel previousRadarTimeFrom:[RadarModel buildLatestRadarDate]]];
    //NSURL *url = [NSURL URLWithString:path];
    //NSData *data = [NSData dataWithContentsOfURL:url];

    //UIImage *image = [[UIImage alloc] initWithData:data];
    //image = [RadarModel cropRadarImage:image forStationCode:@"XFT"];
        
    //[[RadarModel singleton] test];
//    [[RadarModel singleton] setCurrentRadarFrame:image];
    //((RadarModel*)[RadarModel singleton]).currentRadarFrame = image;
    //self.imageView.image = image;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshSelected:nil];
    
    /*self.imageView.image = [[RadarModel singleton] getLatestRadarFrame];
    
    // Should we show the radar circles?
    // TODO do this
    
    CGSize size = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = size;
    
    self.scrollContainer.frame = self.imageView.frame;*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //return self.imageView;
    return self.scrollContainer;
}

-(void)scrollViewDidZoom:(UIScrollView*)scrollView
{
    // This code keeps the sub-view centered when the user zooms below 1.0 (otherwise the radar image would go in the top left corner)
    
    for (UIView* subView in [scrollView.subviews objectEnumerator])
    {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0);
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0);
    
        subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
    
    // Update size of location marker (so its size doesn't appear to change)
    self.locationMarker.transform = CGAffineTransformMakeScale(1/scrollView.zoomScale, 1/scrollView.zoomScale);
}


- (IBAction)refreshSelected:(id)sender {
    [[RadarModel singleton] getLatestRadarFrameAsync:^(BOOL didSucceed, UIImage *radarImage) {
        self.imageView.image = radarImage;
        
        CGSize size = self.imageView.image.size;
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentSize = size;
        
        self.scrollContainer.frame = self.imageView.frame;
    
        [self refreshLocation];
    }];
}

- (void)refreshLocation {
    // Start by hiding the current marker (since it probably has an incorrect location right now)
    [self.locationMarker setHidden:YES];
    
    // Now start receiving location notifications
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"got location update.");
    CLLocation *location = [locations lastObject];
    if (location)
    {
        
        [self.locationMarker setHidden:NO];
        NSLog(@"Received location: %@", location);
        
        // Can stop getting location updates now.
        [locationManager stopUpdatingLocation];
    }
}

-(void) updateLocationMarketWithLocation:(CLLocation*)location
{
    if (!location)
        return;
    
    // Get current station coordinates
    NSArray* stationData = [RadarModel getCurrentStationCode];
    
    // Get two refrence points for station
    NSNumber x1, x2, y1, y2, g1, g2;
    
    [self.locationMarker setHidden:NO];
}

@end
