//
//  UNRTextureMap.h
//  UNRMapViewer
//
//  Created by Bill Dudney on 7/16/11.
//  Copyright 2011 Gala Factory Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class UNRTexture;
struct UNRNode;

@interface UNRTextureMap : NSObject

- (id)initWithSize:(CGSize)size;

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) GLuint lightMapTexID;

- (void)addTexturesFromNode:(struct UNRNode *)node;
- (void)uploadToGPU;

@end
