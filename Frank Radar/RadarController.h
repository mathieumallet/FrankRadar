//
//  FirstViewController.h
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-14.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RadarController : UIViewController

@property UIImageView *locationMarker;
@property UIImageView *imageView;
@property UIView *scrollContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void) setSelectedCell: (NSIndexPath *) indexPath andTableView: (UITableView *) tableView;
- (IBAction)refreshSelected:(id)sender;


@end
