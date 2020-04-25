//
//  RadarModel.h
//  Frank Radar
//
//  Created by Mathieu Mallet on 2013-09-15.
//  Copyright (c) 2013 Equinox Synthetics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
@interface RadarModel : NSObject
{
    NSDate* currentRadarTime;
    
    NSMutableArray* radarTimes;
}

+(RadarModel*) singleton;
+(NSDictionary*) databaseArray;
+(NSDictionary*) databaseMap;

@property UIImage* currentRadarFrame;
@property NSMutableArray* radarFrames;

+(NSString*) getCurrentStationCode;
+(NSArray*) getCurrentStationData;

-(void) downloadLatestRadarFrame;
-(void) downloadMissingFrames;
-(void) downloadFrameAtTime:(NSDate*) aDate;

-(BOOL) currentFrameIsOutOfDate;

-(UIImage*) getLatestRadarFrame;
-(void) setLatestRadarFrame:(UIImage*) aImage;

+(NSString*) buildRadarURLWithStation:(NSString*) aStation andDate:(NSDate*) aDate;
+(NSDate*) buildLatestRadarDate;
+(NSDate*) previousRadarTimeFrom:(NSDate*) aDate;

+(UIImage*) cropRadarImage:(UIImage *)anImage forStationCode:(NSString*)stationCode;
+(UIImage*) cropImage:(UIImage*) anImage withRect:(CGRect) aRect;
- (void) getLatestRadarFrameAsync:(void (^)(BOOL didSucceed, UIImage *radarImage))downloadedBlock;

@end
