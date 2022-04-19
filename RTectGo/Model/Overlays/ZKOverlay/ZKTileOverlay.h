//
//  ZKTileOverlay.h
//  RTectGo
//
//  Created by Apple on 2019/2/21.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ZKTileOverlay : MKTileOverlay

@property (nonatomic, strong) NSMutableArray * urls;

-(id) initWithArray:(NSMutableArray *)urls;

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path; // default implementation fills out the URLTemplate

@end
