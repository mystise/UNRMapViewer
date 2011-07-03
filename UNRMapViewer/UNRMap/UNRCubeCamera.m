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

@synthesize drX = drX_, drY = drY_, drZ = drZ_, cam = cam_;

- (id)init{
	self = [super init];
	if(self){
		UNRCamera *cam = [[UNRCamera alloc] init];
		self.cam = cam;
		[cam release];
	}
	return self;
}

- (void)updateWithTimestep:(float)dt{
	self.cam.rotX += self.drX*dt;
	self.cam.rotY += self.drY*dt;
	self.cam.rotZ += self.drZ*dt;
}

- (void)drawWithRootNode:(UNRNode *)rootNode camera:(UNRCamera *)cam projMat:(Matrix3D)projection{
	//create a matrix from the camPos and the rotation
	//draw the rootNode with the matrix
	
	UNRCamera *newCam = [self.cam copy];
	newCam.rotX += cam.rotX;
	newCam.rotY += cam.rotY;
	newCam.rotZ += cam.rotZ;
	
	Matrix3D modelView, mat;
	[newCam getGLData:modelView];
	[newCam release];
	//Matrix3DUniformScale(modelView, 0.1f);
	
	Matrix3DMultiply(projection, modelView, mat);
	glStencilFunc(GL_EQUAL, 1, UINT_MAX);
	glStencilMask(0);
	Vector3D camPos = self.cam.pos;
//	camPos.x = -camPos.x;
//	camPos.y = -camPos.y;
//	camPos.z = -camPos.z;
	[rootNode drawWithMatrix:mat camPos:camPos];
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
	glStencilMask(UINT_MAX);
}

- (void)dealloc{
	[cam_ release];
	cam_ = nil;
	[super dealloc];
}

@end
