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
		/*Matrix3D mat;
		 mat.translate(-vec.x, -vec.y, -vec.z);
		 
		 Matrix3D mat2;
		 
		 {
		 Matrix3D mat;
		 mat.rotateZ(-rotZ);
		 mat.rotateY(-rotY);
		 mat.rotateX(-rotX);
		 
		 prepare();
		 
		 mat2[0] = right.x;
		 mat2[4] = right.y;
		 mat2[8] = right.z;
		 
		 mat2[1] = up.x;
		 mat2[5] = up.y;
		 mat2[9] = up.z;
		 
		 mat2[2] = look.x;
		 mat2[6] = look.y;
		 mat2[10] = look.z;
		 
		 mat2 = mat2 * mat;
		 }
		 
		 mat = mat2 * mat;
		 
		 pos += Vector3D(mat[12], mat[13], mat[14]);*/
		Matrix3D mat1, mat2, result;
		Matrix3DIdentity(mat1);
		Matrix3DIdentity(mat2);
		Matrix3DIdentity(result);
		Matrix3DTranslate(mat1, -moveVec.x, -moveVec.y, -moveVec.z);
		
		{
			Matrix3D mat, mat1;
			Matrix3DIdentity(mat);
			Matrix3DIdentity(mat1);
			Matrix3DRotateZ(mat, -self.rotZ);
			Matrix3DRotateY(mat, -self.rotY);
			Matrix3DRotateX(mat, -self.rotX);
			
			[self prepare];
			
			mat1[0] = self.right.x;
			mat1[4] = self.right.y;
			mat1[8] = self.right.z;
			
			mat1[1] = self.up.x;
			mat1[5] = self.up.y;
			mat1[9] = self.up.z;
			
			mat1[2] = self.look.x;
			mat1[6] = self.look.y;
			mat1[10] = self.look.z;
			Matrix3DMultiply(mat1, mat, mat2);
		}
		
		Matrix3DMultiply(mat2, mat1, result);
		
		self.pos = Vector3DAdd(self.pos, Vector3DCreate(result[12], result[13], result[14]));
	}
}

- (void)prepare{
	self.right = Vector3DCross(self.look, self.up);
	self.up = Vector3DCross(self.right, self.look);
	
	Vector3DNormalize(&right_);
	Vector3DNormalize(&up_);
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
	Vector3DNormalize(&look);
	look_ = look;
}

@end
