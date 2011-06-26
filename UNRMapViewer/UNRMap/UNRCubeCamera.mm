//
//  UNRCubeCamera.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRCubeCamera.h"

#import "UNRNode.h"

#import "Matrix.h"
using Matrix::Matrix3D;

@implementation UNRCubeCamera

@synthesize framebuffer = framebuffer_, renderbuffer = renderbuffer_, depthbuffer = depthbuffer_;
@synthesize tex = tex_, camPos = camPos_, drX = drX_, drY = drY_, drZ = drZ_, rotX = rotX_, rotY = rotY_, rotZ = rotZ_;

- (id)init{
	self = [super init];
	if(self){
		const int texWidth = 128, texHeight = 128;
		
		GLuint tex;
		glGenTextures(1, &tex);
		self.tex = tex;
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_CUBE_MAP, self.tex);
		
		glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		for(int i = 0; i < 6; i++){
			glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X+i, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
		}
		
		glGenFramebuffers(1, &tex);
		self.framebuffer = tex;
		glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer);
		glViewport(0, 0, texWidth, texHeight);
		
		glGenRenderbuffers(1, &tex);
		self.renderbuffer = tex;
		glBindRenderbuffer(GL_RENDERBUFFER, self.renderbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, texWidth, texHeight);
		
		glGenRenderbuffers(1, &tex);
		self.depthbuffer = tex;
		glBindRenderbuffer(GL_RENDERBUFFER, self.depthbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, texWidth, texHeight);
		
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, self.depthbuffer);
		
		self.camPos = new Vector3D();
	}
	return self;
}

- (void)updateWithTimestep:(float)dt{
	self.rotX += self.drX*dt;
	self.rotY += self.drY*dt;
	self.rotZ += self.drZ*dt;
}

- (void)drawWithRootNode:(UNRNode *)rootNode{
	//create a matrix from the camPos and the rotation
	//draw the rootNode with the matrix
	Matrix3D modelView, projection, mat;
	projection.perspective(90.0f, 0.1f, 10000.0f, 1.0f);
	//draw from each of the six views
	modelView.rotateX(-self.rotX);
	modelView.rotateY(-self.rotY);
	modelView.rotateZ(-self.rotZ);
	modelView.transpose();
	modelView.translate(-self.camPos->x, -self.camPos->y, -self.camPos->z);
	modelView.uniformScale(0.1f);
	
	glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer);
	glViewport(0, 0, 128, 128);
	
	for(int i = 0; i < 6; i++){
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_NEGATIVE_X+i, self.tex, 0);
		
		//glClearColor(0.9f, 0.3f, 0.0f+(i*1.0f/6.0f), 1.0f);
		glClearColor(1.0f-(i*1.0f/6.0f), 0.0f, (i*1.0f/6.0f), 1.0f);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	}
	
	/*glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, self.tex, 0);
	
	glClearColor(0.9f, 0.3f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);*/
	
	mat = projection*modelView;
	//[rootNode drawWithMatrix:mat cubeMap:0 cameraPos:(vec3){self.camPos->x, self.camPos->y, self.camPos->z}];
}

- (void)setCamPos:(Vector3D *)camPos{
	if(camPos_){
		delete camPos_;
	}
	camPos_ = camPos;
}

@end
