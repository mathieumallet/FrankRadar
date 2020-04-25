//
//  RadarModel.m
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-15.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import "RadarModel.h"

@implementation RadarModel

static RadarModel* singletonInstance = nil;
static NSArray* databaseArray = nil;
static NSDictionary* databaseMap = nil;

#define RADAR_URL_PREFIX @"http://weather.gc.ca/data/radar/detailed/temp_image"
#define RADAR_URL_MIDDLE @"PRECIP_RAIN"
#define RADAR_IMAGE_BOUNDS CGRectMake(1, 1, 478, 478)
#define RADAR_CIRCLES_SIZE CGSizeMake(478, 478)

+(RadarModel*) singleton
{
    if (!singletonInstance)
    {
        singletonInstance = [[RadarModel alloc] init];
        
        // We also initialize the dictionnary here
        
        // Keys of the dictionary is the station code
        // Values of the dictionary is an array with the following items: Region, station name, station proximity-to-what, x coord of first gps point,  coord of first gps point, latitude of first gps point, longitute of first gps point, x coord of second gps point, y coord of second gps point, latitude of second gps point, longitude of second gps point, latitude of gps station, longitute of gps station
        // Station name is nil when using provincial or country-wide radar
        // 'proximity-to-what' is nil when the station name is well-known
        
        databaseArray = [[NSArray alloc] initWithObjects:
                    
                    [[NSArray alloc] initWithObjects:@"COMPOSITE_NAT", @"Composites", @"Canada-wide", @"", [NSNumber numberWithFloat:123.345f], nil],
                    
                    [[NSArray alloc] initWithObjects:@"COMPOSITE_PAC", @"Composites", @"Pacific region", @"", [NSNumber numberWithFloat:123.345f], nil],
                    
                    [[NSArray alloc] initWithObjects:@"COMPOSITE_WRN", @"Composites", @"Prairies region", @"", [NSNumber numberWithFloat:123.345f], nil],
                         
                    [[NSArray alloc] initWithObjects:@"COMPOSITE_ONT", @"Composites", @"Ontario region", @"", [NSNumber numberWithFloat:123.345f], nil],
                         
                    [[NSArray alloc] initWithObjects:@"XFT", @"Ontario", @"Franktown", @"Ottawa", [NSNumber numberWithFloat:123.345f], nil],
                    
                    [[NSArray alloc] initWithObjects:@"WKR", @"Ontario", @"King City", @"Toronto", [NSNumber numberWithFloat:123.345f], nil],
                    
                    [[NSArray alloc] initWithObjects:@"XNC", @"Atlantic", @"Chipman", @"Fredericton", [NSNumber numberWithFloat:123.345f], nil],
                    
                    nil];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        for (id key in databaseArray)
        {
            [dict setObject:key forKey:[key objectAtIndex:0]];
        }
        databaseMap = [NSDictionary dictionaryWithDictionary:dict];
    }
    return singletonInstance;
}

+(NSDictionary*) databaseMap
{
    if (!singletonInstance)
        [RadarModel singleton];
    return databaseMap;
}

+(NSArray*) databaseArray
{
    if (!singletonInstance)
        [RadarModel singleton];
    return databaseArray;
}

@synthesize currentRadarFrame;
@synthesize radarFrames;

// a temporary function that downloads the latest available radar frame. if the computed latest radar frame doesn't exist, downloads the previous frame instead.
-(void) downloadLatestRadarFrame
{
    
}

+(NSString*) buildRadarURLWithStation:(NSString *)aStation andDate:(NSDate *)aDate
{
    // Extract date components from date
    if (!aDate)
        aDate = [[NSDate alloc] init];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy_MM_dd_HH_mm"];
    NSTimeZone* timezone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timezone];
    NSString* dateFragment = [formatter stringFromDate:aDate];
    
    NSString* result = [NSString stringWithFormat:@"%@/%@/%@_%@_%@.GIF", RADAR_URL_PREFIX, aStation, aStation, RADAR_URL_MIDDLE, dateFragment];
    NSLog(@"Computed url: %@", result);
    return result;
}

// this function computes the date with rounded off minute value (and 0 seconds) based on the current date
+(NSDate*) buildLatestRadarDate
{
    NSDate *current = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:current];
    NSInteger minutes = [components minute];
    int newMinutes = (minutes / 10) * 10;
    components.minute = newMinutes;
    components.second = 0;
    
    NSDate *targetDate = [calendar dateFromComponents:components];
    return targetDate;
}

+(NSDate*) previousRadarTimeFrom:(NSDate*) aDate
{
    return [aDate dateByAddingTimeInterval:(-10 * 60)];
}

-(UIImage*) getLatestRadarFrame
{
    // TODO: do loading from separate thread (eventually)
    // TODO: cache values as needed (e.g. only reload data if needed)
    NSString *stationCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"dataSource"];
    if (stationCode == nil)
        stationCode = @"XFT";
    NSString *path = [RadarModel buildRadarURLWithStation:stationCode andDate:[RadarModel previousRadarTimeFrom:[RadarModel buildLatestRadarDate]]];
    NSURL *url = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    UIImage *image = [[UIImage alloc] initWithData:data];
    image = [RadarModel cropRadarImage:image forStationCode:stationCode];
    currentRadarFrame = image;
    
    NSLog(@"data loaded from URL");
    
    return currentRadarFrame;
}

-(void) setLatestRadarFrame:(UIImage*) aImage
{
    currentRadarFrame = aImage;
}

+(UIImage*) cropRadarImage:(UIImage *)anImage forStationCode:(NSString*)stationCode
{
    // No cropping necessary for the 'Canada-wide' image
    if ([stationCode isEqualToString:@"COMPOSITE_NAT"])
        return anImage;
    
    // Build cropping rectangle -- this is used to allow app to be used with radar frames of varying sizes (e.g. the region composites)
    CGRect bounds = CGRectMake(1, 1, [anImage size].width - 102, [anImage size].height - 2);
    
    //return [RadarModel cropImage:anImage withRect:RADAR_IMAGE_BOUNDS];
    return [RadarModel cropImage:anImage withRect:bounds];
}

+(UIImage*) cropImage:(UIImage *)anImage withRect:(CGRect)aRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([anImage CGImage], aRect);
    UIImage* result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

+(NSString*) getCurrentStationCode {
    NSString *stationCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"dataSource"];
    if (stationCode == nil)
        return @"XFT";
    return stationCode;
}

+(NSArray*) getCurrentStationData {
    NSString *stationCode = [RadarModel getCurrentStationCode];
    return [[RadarModel databaseMap] objectForKey:stationCode];
}

- (void) getLatestRadarFrameAsync:(void (^)(BOOL didSucceed, UIImage *radarImage))downloadedBlock
{
    NSString* stationCode = [RadarModel getCurrentStationCode];
    NSString *path = [RadarModel buildRadarURLWithStation:stationCode andDate:[RadarModel previousRadarTimeFrom:[RadarModel buildLatestRadarDate]]];
    NSURL *url = [NSURL URLWithString:path];
    
    [RadarModel downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
        
        UIImage *cropped;
        if (!succeeded)
            cropped = nil;
        else
            cropped = [RadarModel cropRadarImage:image forStationCode:stationCode];
        
        currentRadarFrame = cropped;
        
       if (downloadedBlock)
       {
           if (succeeded)
               downloadedBlock(YES, cropped);
           else
               downloadedBlock(NO, nil);
       }
    }];
}

@end
