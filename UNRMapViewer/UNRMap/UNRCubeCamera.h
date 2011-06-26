//
//  UNRCubeCamera.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Vector.h"
using Vector::Vector3D;

@class UNRNode;

@interface UNRCubeCamera : NSObject {
    
}

- (void)updateWithTimestep:(float)dt;
- (void)drawWithRootNode:(UNRNode *)rootNode;

@property(nonatomic, assign) GLuint tex;
@property(nonatomic, assign) GLuint framebuffer, renderbuffer, depthbuffer;
@property(nonatomic, assign) Vector3D *camPos;
@property(nonatomic, assign) float rotX, rotY, rotZ;
@property(nonatomic, assign) float drX, drY, drZ;

@end
