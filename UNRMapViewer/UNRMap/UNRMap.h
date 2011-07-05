//
//  UNRMap.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class UNRFile, UNRNode, UNRCubeCamera, UNRCamera;

@interface UNRMap : NSObject {
	
}

- (id)initWithLevel:(NSMutableDictionary *)level andFile:(UNRFile *)file label:(UILabel *)label progress:(UIProgressView *)progress;
- (void)draw:(float)aspect withTimestep:(float)dt;

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
@property(nonatomic, retain) NSMutableDictionary *zones;
@property(nonatomic, retain) NSMutableDictionary *actors;
@property(nonatomic, assign) CGPoint stickPos, stickPrevPos, lookPos, lookPrevPos;
//@property(nonatomic, assign) GLuint mapVbo;

@end
