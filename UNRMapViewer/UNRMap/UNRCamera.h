//
//  UNRCamera.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix3D.h"
#import "Vector3D.h"

@interface UNRCamera : NSObject {
    
}

- (void)getGLData:(Matrix3D)retMat;
- (void)move:(Vector3D)moveVec;

@property(nonatomic, assign) Vector3D pos, up, look, right;
@property(nonatomic, assign) float rotX, rotY, rotZ, xClamp;

@end
