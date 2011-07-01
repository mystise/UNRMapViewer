//
//  UNRCubeCamera.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRCubeCamera.h"

#import "UNRNode.h"
#import "UNRCamera.h"

@implementation UNRCubeCamera

@synthesize camPos = camPos_, drX = drX_, drY = drY_, drZ = drZ_, rotX = rotX_, rotY = rotY_, rotZ = rotZ_;

/*- (id)init{
	self = [super init];
	if(self){
	}
	return self;
}*/

- (void)updateWithTimestep:(float)dt{
	self.rotX += self.drX*dt;
	self.rotY += self.drY*dt;
	self.rotZ += self.drZ*dt;
}

- (void)drawWithRootNode:(UNRNode *)rootNode camera:(UNRCamera *)cam{
	//create a matrix from the camPos and the rotation
	//draw the rootNode with the matrix
	Matrix3D modelView, projection, mat;
	Matrix3DPerspective(projection, 90.0f, 0.1f, USHRT_MAX/10.0f, 1.0f);
	Matrix3DRotateX(modelView, RADIANS_TO_DEGREES(self.rotX));
	Matrix3DRotateY(modelView, RADIANS_TO_DEGREES(self.rotY));
	Matrix3DRotateZ(modelView, RADIANS_TO_DEGREES(self.rotZ));
	Matrix3DUniformScale(modelView, 0.1f);
	Matrix3DTranslate(modelView, self.camPos.x, -self.camPos.y, -self.camPos.z);
	Matrix3DScale(modelView, -1.0f, 1.0f, 1.0f);
	
	Matrix3DMultiply(projection, modelView, mat);
	glStencilFunc(GL_EQUAL, 1, UINT_MAX);
	[rootNode drawWithMatrix:mat cameraPos:self.camPos];
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
}

- (void)dealloc{
	[super dealloc];
}

@end
