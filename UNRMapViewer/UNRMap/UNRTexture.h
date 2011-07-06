//
//  UNRTextureExporter.h
//  UNRTextureExporter
//
//  Created by Adalynn Dudney on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Unreal.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct{
	Byte r, g, b, a;
}color;

@class UNRNode;

@interface UNRTexture : NSObject {
	
}

+ (id)textureWithObject:(NSMutableDictionary *)obj attributes:(NSDictionary *)attrib;
+ (id)textureWithLightMap:(NSMutableDictionary *)lightMap data:(NSMutableData *)data lights:(NSMutableArray *)lights node:(UNRNode *)node;
- (void)bind:(int)index;

@property(nonatomic, assign) int width, height;
@property(nonatomic, assign) GLuint glTex;

@end
