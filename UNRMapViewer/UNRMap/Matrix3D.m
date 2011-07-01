//
//  Matrix3D.c
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Matrix3D.h"

void Matrix3DIdentity(Matrix3D mat){
	mat[0] = 1.0f;
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[5] = 1.0f;
	mat[6] = mat[7] = mat[8] = mat[9] = 0.0f;
	mat[10] = 1.0f;
	mat[11] = mat[12] = mat[13] = mat[14] = 0.0f;
	mat[15] = 1.0f;
}

void Matrix3DCopy(Matrix3D mat, Matrix3D res){
	for(int i = 0; i < 16; i++){
		res[i] = mat[i];
	}
}

void Matrix3DTranspose(Matrix3D mat){
	Matrix3D temp;
	for(int i = 0; i < 4; i++){
		for(int j = 0; j < 4; j++){
			temp[j*4 + i] = mat[i*4 + j];
		}
	}
	Matrix3DCopy(temp, mat);
}

void Matrix3DMultiply(Matrix3D mat1, Matrix3D mat2, Matrix3D res){
	res[0] = mat1[0]  * mat2[0]  + mat1[4] * mat2[1]  + mat1[8]  * mat2[2]  + mat1[12] * mat2[3];
	res[1] = mat1[1]  * mat2[0]  + mat1[5] * mat2[1]  + mat1[9]  * mat2[2]  + mat1[13] * mat2[3];
	res[2] = mat1[2]  * mat2[0]  + mat1[6] * mat2[1]  + mat1[10] * mat2[2]  + mat1[14] * mat2[3];
	res[3] = mat1[3]  * mat2[0]  + mat1[7] * mat2[1]  + mat1[11] * mat2[2]  + mat1[15] * mat2[3];
	
	res[4] = mat1[0]  * mat2[4]  + mat1[4] * mat2[5]  + mat1[8]  * mat2[6]  + mat1[12] * mat2[7];
	res[5] = mat1[1]  * mat2[4]  + mat1[5] * mat2[5]  + mat1[9]  * mat2[6]  + mat1[13] * mat2[7];
	res[6] = mat1[2]  * mat2[4]  + mat1[6] * mat2[5]  + mat1[10] * mat2[6]  + mat1[14] * mat2[7];
	res[7] = mat1[3]  * mat2[4]  + mat1[7] * mat2[5]  + mat1[11] * mat2[6]  + mat1[15] * mat2[7];
	
	res[8] = mat1[0]  * mat2[8]  + mat1[4] * mat2[9]  + mat1[8]  * mat2[10] + mat1[12] * mat2[11];
	res[9] = mat1[1]  * mat2[8]  + mat1[5] * mat2[9]  + mat1[9]  * mat2[10] + mat1[13] * mat2[11];
	res[10] = mat1[2] * mat2[8]  + mat1[6] * mat2[9]  + mat1[10] * mat2[10] + mat1[14] * mat2[11];
	res[11] = mat1[3] * mat2[8]  + mat1[7] * mat2[9]  + mat1[11] * mat2[10] + mat1[15] * mat2[11];
	
	res[12] = mat1[0] * mat2[12] + mat1[4] * mat2[13] + mat1[8]  * mat2[14] + mat1[12] * mat2[15];
	res[13] = mat1[1] * mat2[12] + mat1[5] * mat2[13] + mat1[9]  * mat2[14] + mat1[13] * mat2[15];
	res[14] = mat1[2] * mat2[12] + mat1[6] * mat2[13] + mat1[10] * mat2[14] + mat1[14] * mat2[15];
	res[15] = mat1[3] * mat2[12] + mat1[7] * mat2[13] + mat1[11] * mat2[14] + mat1[15] * mat2[15];
}

void Matrix3DMultEqual(Matrix3D mat1, Matrix3D mat2){
	Matrix3D mat;
	Matrix3DMultiply(mat1, mat2, mat);
	Matrix3DCopy(mat, mat1);
}

void Matrix3DRotateX(Matrix3D mat, float degrees){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	float rad = DEGREES_TO_RADIANS(degrees);
	
	retMat[5] = cosf(rad);
	retMat[6] = -sinf(rad);
	retMat[9] = -retMat[6];
	retMat[10] = retMat[5];
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DRotateY(Matrix3D mat, float degrees){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	float rad = DEGREES_TO_RADIANS(degrees);
	
	retMat[0] = cosf(rad);
	retMat[2] = sinf(rad);
	retMat[8] = -retMat[2];
	retMat[10] = retMat[0];
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DRotateZ(Matrix3D mat, float degrees){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	float rad = DEGREES_TO_RADIANS(degrees);
	
	retMat[0] = cosf(rad);
	retMat[1] = sinf(rad);
	retMat[4] = -retMat[1];
	retMat[5] = retMat[0];
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DRotate(Matrix3D mat, float degrees, float x, float y, float z){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	float rad = DEGREES_TO_RADIANS(degrees);
	
	float mag = sqrtf((x * x) + (y * y) + (z * z));
	if(mag == 0.0f){
		x = 1.0f;
		y = 0.0f;
		z = 0.0f;
	}else if(mag != 1.0f){
		x /= mag;
		y /= mag;
		z /= mag;
	}
	float c = cosf(rad);
	float s = sinf(rad);
	
	retMat[0] = (x * x) * (1-c) + c;
	retMat[1] = (x * y) * (1-c) + (z * s);
	retMat[2] = (x * z) * (1-c) - (y * s);
	
	retMat[4] = (y * x) * (1-c) - (z * s);
	retMat[5] = (y * y) * (1-c) + c;
	retMat[6] = (y * z) * (1-c) + (x * s);
	
	retMat[8] = (z * x) * (1-c) + (y * s);
	retMat[9] = (z * y) * (1-c) - (x * s);
	retMat[10] = (z * z)* (1-c) + c;
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DTranslate(Matrix3D mat, float x, float y, float z){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	
	retMat[12] = x;
	retMat[13] = y;
	retMat[14] = z;
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DScale(Matrix3D mat, float x, float y, float z){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	
	retMat[0] = x;
	retMat[5] = y;
	retMat[10] = z;
	
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DUniformScale(Matrix3D mat, float s){
	Matrix3DScale(mat, s, s, s);
}

void Matrix3DOrthographic(Matrix3D mat, float left, float right, float bottom, float top, float near, float far){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	retMat[0] = 2.0f / (right - left);
	retMat[5] = 2.0f / (top - bottom);
	retMat[10] = -2.0f / (far - near);
	retMat[12] = (right + left) / (right - left);
	retMat[13] = (top + bottom) / (top - bottom);
	retMat[14] = (far + near) / (far - near);
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DFrustum(Matrix3D mat, float left, float right, float bottom, float top, float near, float far){
	Matrix3D retMat;
	Matrix3DIdentity(retMat);
	retMat[0] = 2.0f * near / (right - left);
	retMat[5] = 2.0f * near / (top - bottom);
	retMat[8] = (right + left) / (right - left);
	retMat[9] = (top + bottom) / (top - bottom);
	retMat[10] = -(far + near) / (far - near);
	retMat[11] = -1.0f;
	retMat[14] = -(2.0f * far * near) / (far - near);
	retMat[15] = 0.0f;
	Matrix3DMultEqual(mat, retMat);
}

void Matrix3DPerspective(Matrix3D mat, float fov, float near, float far, float aspect){
	float size = near * tanf(DEGREES_TO_RADIANS(fov) / 2.0f);
	Matrix3DFrustum(mat, -size, size, -size / aspect, size / aspect, near, far);
}