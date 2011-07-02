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

#import "Matrix3D.h"
#import "Vector3D.h"

@class UNRNode, UNRCamera;

@interface UNRCubeCamera : NSObject {
    
}

- (void)updateWithTimestep:(float)dt;
- (void)drawWithRootNode:(UNRNode *)rootNode camera:(UNRCamera *)cam;

@property(nonatomic, assign) Vector3D camPos;
@property(nonatomic, assign) float rotX, rotY, rotZ;
@property(nonatomic, assign) float drX, drY, drZ;

@end
