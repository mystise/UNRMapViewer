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

#import "Matrix3D.h"
#import "Vector3D.h"

#import "UNRNode.h"
#import "UNRMesh.h"

#import "UNRTextureMap.h"

@class UNRFile, UNRCubeCamera, UNRCamera;

typedef struct{
	int meshUsed;
	Matrix3D matrix;
}UNRMeshContainer;

@interface UNRMap : NSObject {
	
}

- (id)initWithLevel:(NSMutableDictionary *)level andFile:(UNRFile *)file label:(UILabel *)label progress:(UIProgressView *)progress;
- (void)draw:(float)aspect withTimestep:(float)dt;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property(nonatomic, assign) UNRNode *rootNode;
@property(nonatomic, assign) UNRMesh **meshes;
@property(nonatomic, assign) int meshCount;
@property(nonatomic, assign) UNRMeshContainer *meshMats;
@property(nonatomic, assign) int meshMatCount;
@property(nonatomic, assign) CGPoint stickPos, stickPrevPos, lookPos, lookPrevPos;

@property(nonatomic, retain) UNRTextureMap *lightMapTexMap;
@property(nonatomic, retain) UNRCubeCamera *cubeMap;
@property(nonatomic, retain) UNRCamera *cam;
@property(nonatomic, retain) NSMutableDictionary *textures, *shaders, *lightMaps, *actors, *classes;

@end
