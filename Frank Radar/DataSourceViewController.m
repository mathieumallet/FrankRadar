//
//  DataSourceViewController.m
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-24.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import "DataSourceViewController.h"
#import "RadarModel.h"

@interface DataSourceViewController ()

@end

@implementation DataSourceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    groups = [NSMutableArray array];
    items = [NSMutableDictionary dictionary];
    NSMutableSet* groupNames = [NSMutableSet set];
    NSNumber* groupID = [NSNumber numberWithInt:0];
    
    // first add the 'auto select' item
    [groups addObject:@"Special"];
    [items setValue:[NSArray arrayWithObject:@"Auto-select"] forKey:@"0"];
    
    for (id value in [RadarModel databaseArray])
    {
        NSString* groupName = [value objectAtIndex:1];
        if (![groupNames containsObject:groupName])
        {
            [groupNames addObject:groupName];
            [groups addObject:groupName];
            groupID = [NSNumber numberWithInt:[groupID intValue] + 1];
        }
        
        // Add to dictionnary
        NSMutableArray* array = [items valueForKey:[groupID stringValue]];
        if (array == nil)
        {
            array = [NSMutableArray array];
            [items setValue:array forKey:[groupID stringValue]];
        }
        [array addObject:[value objectAtIndex:0]];
    }
    
    //NSLog(@"groups: %@", groups);
    //NSLog(@"items: %@", items);
    //NSLog(@"data array: %@", [RadarModel databaseArray]);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[items valueForKey:[[NSNumber numberWithInt:section] stringValue]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray* array = [items valueForKey:[[NSNumber numberWithInt:indexPath.section] stringValue]];
    NSString* stationCode = [array objectAtIndex:indexPath.row];
    
    NSString* title = [[[RadarModel databaseMap] valueForKey:stationCode] objectAtIndex:2];
    if (title == nil)
        title = @"Auto-select based on location";
    cell.textLabel.text = title;
    
    NSString* nearWhat = [[[RadarModel databaseMap] valueForKey:stationCode]objectAtIndex:3];
    if (nearWhat == nil || [nearWhat isEqualToString:@""])
        cell.detailTextLabel.text = @"";
    else
        cell.detailTextLabel.text = [@"near " stringByAppendingString:nearWhat];
    
    // TODO: set checkmark if this is the currently-selected station
    NSString* selection = [[NSUserDefaults standardUserDefaults] stringForKey:@"dataSource"];
    if ([selection isEqualToString:stationCode] || (selection == nil && [stationCode isEqualToString:@"Auto-select"]))
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [groups objectAtIndex:section];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    // Which station code is this selection associated with?
    NSArray* array = [items valueForKey:[[NSNumber numberWithInt:indexPath.section] stringValue]];
    NSString* stationCode = [array objectAtIndex:indexPath.row];
    if ([[RadarModel databaseMap] valueForKey:stationCode] == nil)
        stationCode = nil;
    
    // Update cell (not really necessary)
    //[self setSelectedCell:indexPath andTableView:tableView];
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Store selection
    [[NSUserDefaults standardUserDefaults] setValue:stationCode forKey:@"dataSource"];
    
    // Dismiss view
    [self.navigationController popViewControllerAnimated:true];
}

- (void) setSelectedCell: (NSIndexPath *) indexPath andTableView: (UITableView *) tableView
{
    // This doesn't appear to work.
    /*if (id testIndexPath in [tableView indexPathsForVisibleRows])
    {
        if ([testIndexPath isEqual:indexPath])
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        else
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
