//
//  UNRCamera.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRCamera.h"

@interface UNRCamera()

- (void)prepare;

@end

@implementation UNRCamera

@synthesize pos = pos_, up = up_, look = look_, right = right_;
@synthesize rotX = rotX_, rotY = rotY_, rotZ = rotZ_, xClamp = xClamp_;

- (id)init{
	self = [super init];
	if(self){
		self.xClamp = 90.0f;
		self.up = Vector3DCreate(0.0f, 1.0f, 0.0f);
		self.look = Vector3DCreate(0.0f, 0.0f, -1.0f);
	}
	return self;
}

- (void)getGLData:(Matrix3D)retMat{
	Matrix3DIdentity(retMat);
	
	Matrix3D mat1, mat2, mat3;
	Matrix3DIdentity(mat1);
	Matrix3DIdentity(mat2);
	Matrix3DIdentity(mat3);
	
	Matrix3DRotateX(mat1, -self.rotX);
	Matrix3DRotateY(mat1, -self.rotY);
	Matrix3DRotateZ(mat1, -self.rotZ);
	
	[self prepare];
	
	mat2[0] = self.right.x;
	mat2[4] = self.right.y;
	mat2[8] = self.right.z;
	
	mat2[1] = self.up.x;
	mat2[5] = self.up.y;
	mat2[9] = self.up.z;
	
	mat2[2] = -self.look.x;
	mat2[6] = -self.look.y;
	mat2[10] = -self.look.z;
	
	Matrix3DTranslate(mat3, -self.pos.x, -self.pos.y, -self.pos.z);
	
	Matrix3D tempMat;
	Matrix3DMultiply(mat1, mat2, tempMat);
	Matrix3DMultiply(tempMat, mat3, retMat);
}

- (void)move:(Vector3D)moveVec{
	if(Vector3DMagnitude(moveVec) != 0){
		Matrix3D transMat, rotMat, result;
		Matrix3DIdentity(transMat);
		Matrix3DIdentity(rotMat);
		Matrix3DIdentity(result);
		
		{
			Matrix3D fpsLookMat, lookMat;
			Matrix3DIdentity(fpsLookMat);
			Matrix3DIdentity(lookMat);
			Matrix3DRotateZ(fpsLookMat, -self.rotZ);
			Matrix3DRotateY(fpsLookMat, -self.rotY);
			Matrix3DRotateX(fpsLookMat, -self.rotX);
			
			[self prepare];
			
			lookMat[0] = self.right.x;
			lookMat[4] = self.right.y;
			lookMat[8] = self.right.z;
			
			lookMat[1] = self.up.x;
			lookMat[5] = self.up.y;
			lookMat[9] = self.up.z;
			
			lookMat[2] = self.look.x;
			lookMat[6] = self.look.y;
			lookMat[10] = self.look.z;
			Matrix3DMultiply(lookMat, fpsLookMat, rotMat);
		}
		
		Matrix3DTranslate(transMat, -moveVec.x, -moveVec.y, -moveVec.z);
		
		Matrix3DMultiply(rotMat, transMat, result);
		
		self.pos = Vector3DAdd(self.pos, Vector3DCreate(result[12], result[13], result[14]));
	}
}

- (void)prepare{
	self.right = Vector3DCross(self.look, self.up);
	self.up = Vector3DCross(self.right, self.look);
	
	Vector3DNormalizeEqual(&right_);
	Vector3DNormalizeEqual(&up_);
}

//clearly incorrect
- (Vector3D)viewVec{
	Vector3D viewVec;
	
	Matrix3D rotMat;
	
	{
		Matrix3D fpsLookMat, lookMat;
		Matrix3DIdentity(fpsLookMat);
		Matrix3DIdentity(lookMat);
		Matrix3DRotateX(fpsLookMat, -self.rotX);
		Matrix3DRotateY(fpsLookMat, -self.rotY);
		Matrix3DRotateZ(fpsLookMat, -self.rotZ);
		
		[self prepare];
		
		lookMat[0] = self.right.x;
		lookMat[4] = self.right.y;
		lookMat[8] = self.right.z;
		
		lookMat[1] = self.up.x;
		lookMat[5] = self.up.y;
		lookMat[9] = self.up.z;
		
		lookMat[2] = -self.look.x;
		lookMat[6] = -self.look.y;
		lookMat[10] = -self.look.z;
		Matrix3DMultiply(lookMat, fpsLookMat, rotMat);
	}
	
	viewVec.x = rotMat[2];
	viewVec.y = rotMat[6];
	viewVec.z = rotMat[10];
	
	return viewVec;
}

- (void)setRotX:(float)rotX{
	rotX_ = rotX;
	if(rotX_ > xClamp_){
		rotX_ = xClamp_;
	}else if(rotX_ < -xClamp_){
		rotX_ = -xClamp_;
	}
}

- (void)setLook:(Vector3D)look{
	look_ = Vector3DNormalize(look);
}

@end
