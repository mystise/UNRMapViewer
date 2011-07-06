//
//  UNRZone.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNRZone : NSObject {
    
}

- (id)initWithZone:(NSMutableDictionary *)zone index:(int)zoneIndex;

- (BOOL)isZoneVisible:(UNRZone *)zone;
- (BOOL)isVisibleFromZone:(UNRZone *)zone;

@property(nonatomic, assign) long long visibility;
@property(nonatomic, assign) long long connectivity;
@property(nonatomic, assign) int zoneIndex;

@end