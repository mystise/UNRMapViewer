//
//  UNRCubeCamera.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRCubeCamera.h"

#import "UNRNode.h"

@implementation UNRCubeCamera

@synthesize camPos = camPos_, drX = drX_, drY = drY_, drZ = drZ_, rotX = rotX_, rotY = rotY_, rotZ = rotZ_;

- (id)init{
	self = [super init];
	if(self){
		self.camPos = new Vector3D();
	}
	return self;
}

- (void)updateWithTimestep:(float)dt{
	self.rotX += self.drX*dt;
	self.rotY += self.drY*dt;
	self.rotZ += self.drZ*dt;
}

- (void)drawWithRootNode:(UNRNode *)rootNode baseMatrix:(const Matrix3D &)inMat{
	//create a matrix from the camPos and the rotation
	//draw the rootNode with the matrix
	Matrix3D modelView = inMat, projection, mat;
	projection.perspective(90.0f, 0.1f, USHRT_MAX/10.0f, 1.0f);
	modelView.rotateX(RADIANS_TO_DEGREES(self.rotX));
	modelView.rotateY(RADIANS_TO_DEGREES(self.rotY));
	modelView.rotateZ(RADIANS_TO_DEGREES(self.rotZ));
	modelView.uniformScale(0.1f);
	modelView.translate(self.camPos->x, -self.camPos->y, -self.camPos->z);
	modelView.scale(-1.0f, 1.0f, 1.0f);
	
	mat = projection*modelView;
	glStencilFunc(GL_EQUAL, 1, UINT_MAX);
	[rootNode drawWithMatrix:mat cameraPos:(vec3){self.camPos->x, self.camPos->y, self.camPos->z}];
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
}

- (void)setCamPos:(Vector3D *)camPos{
	if(camPos_){
		delete camPos_;
	}
	camPos_ = camPos;
}

- (void)dealloc{
	if(camPos_){
		delete camPos_;
		camPos_ = NULL;
	}
	[super dealloc];
}

@end
