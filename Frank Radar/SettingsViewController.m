//
//  SettingsViewController.m
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-22.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import "SettingsViewController.h"
#import "RadarModel.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get and set value for 'show location'
    bool showLocation = [[NSUserDefaults standardUserDefaults] boolForKey:@"showLocation"];
    [self.showLocationSwitch setOn:showLocation];
    
    // Get data source
    NSString* stationCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"dataSource"];
    if (stationCode == nil)
        [self.dataSourceLabel setText:@"Auto-select based on location"];
    else
        [self.dataSourceLabel setText:[[[RadarModel databaseMap] valueForKey:stationCode] objectAtIndex:2]];
}

@end
