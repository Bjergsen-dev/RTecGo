//
//  ZKTileOverlay.m
//  RTectGo
//
//  Created by Apple on 2019/2/21.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import "ZKTileOverlay.h"

@implementation ZKTileOverlay


-(id) initWithArray:(NSMutableArray *)urls
{
    self = [super init];
    if (self) {
        _urls = urls;
    }
    
    return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path{

    
    
    NSString * str = [NSString stringWithFormat:@"x=%ld&y=%ld&z=%ld.png",(long)path.x,(long)path.y,(long)path.z];
    NSString *Hpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSString *filePath = [Hpath stringByAppendingPathComponent:str];
    NSURL * url;
    if ([self contains:_urls str:str]) {
        url = [NSURL fileURLWithPath:filePath];
    }else{
        
    }

    return  url;
    
}


- (BOOL) contains:(NSMutableArray *)urls str:(NSString *)str{
    
    for (int i = 0; i < urls.count; i++) {
        NSString * temp = [urls objectAtIndex:i];
        if ([str isEqualToString:temp]) {
            return YES;
        }
    }
    
    return NO;
}

@end
