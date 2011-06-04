//
//  UNRMap.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNRFile, UNRNode;

@interface UNRMap : NSObject {
	
}

- (id)initWithModel:(NSMutableDictionary *)model andFile:(UNRFile *)file;
- (void)draw:(float)aspect;

@property(nonatomic, retain) UNRNode *rootNode;
@property(nonatomic, retain) NSMutableDictionary *textures;
@property(nonatomic, retain) NSMutableDictionary *shaders;

@end
