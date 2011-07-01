//
//  UNRMap.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNRFile, UNRNode, UNRCubeCamera, UNRCamera;

@interface UNRMap : NSObject {
	
}

- (id)initWithModel:(NSMutableDictionary *)model andFile:(UNRFile *)file;
- (void)draw:(float)aspect withTimestep:(float)dt;
- (void)drawCubeMap:(float)dt;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property(nonatomic, retain) UNRNode *rootNode;
@property(nonatomic, retain) UNRCubeCamera *cubeMap;
@property(nonatomic, retain) UNRCamera *cam;
@property(nonatomic, retain) NSMutableDictionary *textures;
@property(nonatomic, retain) NSMutableDictionary *shaders;
@property(nonatomic, retain) NSMutableDictionary *lightMaps;
@property(nonatomic, assign) CGPoint stickPos, stickPrevPos, lookPos, lookPrevPos;

@end
