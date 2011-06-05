/*
 *  GLCommon.h
 *  Hello GL
 *
 *  Created by Adalynn Dudney on 9/3/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define DEGREES_TO_RADIANS(x) ((x) / 180.0f * M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / M_PI * 180.0f)

typedef struct{
	GLfloat x;
	GLfloat y;
	GLfloat z;
}Vertex3D;

typedef Vertex3D Vector3D;

static inline GLfloat Vertex3DDistanceBetweenVerticies(Vertex3D v1, Vertex3D v2){
	GLfloat dX, dY, dZ;
	dX = v2.x - v1.x;
	dY = v2.y - v1.y;
	dZ = v2.z - v1.z;
	return sqrtf((dX * dX) + (dY * dY) + (dZ * dZ));
}

static inline GLfloat Vector3DMagnitude(Vector3D vec){
	return sqrtf((vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z));
}

static inline GLfloat Vector3DDotProduct(Vector3D v1, Vector3D v2){
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

static inline Vector3D Vector3DCrossProduct(Vector3D v1, Vector3D v2){
	Vector3D ret;
	ret.x = (v1.y * v2.z) - (v1.z * v2.y);
	ret.y = (v1.z * v2.x) - (v1.x * v2.z);
	ret.z = (v1.x * v2.y) - (v1.y * v2.x);
	return ret;
}

static inline void Vector3DNormalize(Vector3D *vec){
	GLfloat mag = Vector3DMagnitude(*vec);
	if(mag == 0.0f){
		vec->x = 1.0f;
		vec->y = 0.0f;
		vec->z = 0.0f;
		return;
	}
	vec->x /= mag;
	vec->y /= mag;
	vec->z /= mag;
}

static inline Vector3D Vector3DMakeWithStartAndEndPoints(Vertex3D start, Vertex3D end){
	Vector3D ret;
	ret.x = end.x - start.x;
	ret.y = end.y - start.y;
	ret.z = end.z - start.z;
	return ret;
}

static inline Vector3D Vector3DMakeNormalizedVectorWithStartAndEndPoints(Vertex3D start, Vertex3D end){
	Vector3D ret = Vector3DMakeWithStartAndEndPoints(start, end);
	Vector3DNormalize(&ret);
	return ret;
}

static inline void Vector3DFlip(Vector3D *vec){
	vec->x = -vec->x;
	vec->y = -vec->y;
	vec->z = -vec->z;
}

typedef struct{
	GLfloat red;
	GLfloat green;
	GLfloat blue;
	GLfloat alpha;
}Color;

typedef GLfloat Matrix3D[16];

static inline void Matrix3DSetIdentity(Matrix3D mat){
	mat[0] = mat[5] = mat[10] = mat[15] = 1.0f;
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[6] = mat[7] = mat[8] = mat[9] = 0.0f;
	mat[11] = mat[12] = mat[13] = mat[14] = 0.0f;
}

static inline void Matrix3DsetTranslation(Matrix3D mat, GLfloat x, GLfloat y, GLfloat z){
	mat[0] = mat[5] = mat[10] = mat[15] = 1.0f;
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[6] = mat[7] = mat[8] = mat[9] = 0.0f;
	mat[11] = 0.0;
	mat[12] = x;
	mat[13] = y;
	mat[14] = z;
}

static inline void Matrix3DSetScaling(Matrix3D mat, GLfloat x, GLfloat y, GLfloat z){
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[6] = mat[7] = mat[8] = mat[9] = 0.0f;
	mat[11] = mat[12] = mat[13] = mat[14] = 0.0f;
	mat[0] = x;
	mat[5] = y;
	mat[10] = z;
	mat[15] = 1.0f;
}

static inline void Matrix3DSetUniformScaling(Matrix3D mat, GLfloat scale){
	Matrix3DSetScaling(mat, scale, scale, scale);
}

static inline void Matrix3DSetZRotationUsingRadians(Matrix3D mat, GLfloat rad){
	mat[0] = cosf(rad);
	mat[1] = sinf(rad);
	mat[4] = -mat[1];
	mat[5] = mat[0];
	mat[2] = mat[3] = mat[6] = mat[7] = mat[8] = 0.0f;
	mat[11] = mat[12] = mat[13] = mat[14] = mat[9] = 0.0f;
	mat[10] = mat[15] = 1.0f;
}

static inline void Matrix3DSetZRotationUsingDegrees(Matrix3D mat, GLfloat degrees){
	Matrix3DSetZRotationUsingRadians(mat, DEGREES_TO_RADIANS(degrees));
}

static inline void Matrix3DSetYRotationUsingRadians(Matrix3D mat, GLfloat rad){
	mat[0] = cosf(rad);
	mat[2] = sinf(rad);
	mat[8] = -mat[2];
	mat[10] = mat[0];
	mat[1] = mat[3] = mat[4] = mat[6] = mat[7] = 0.0f;
	mat[9] = mat[11] = mat[13] = mat[12] = mat[14] = 0.0f;
	mat[5] = mat[15] = 1.0f;
}

static inline void Matrix3DSetYRotationUsingDegrees(Matrix3D mat, GLfloat degrees){
	Matrix3DSetYRotationUsingRadians(mat, DEGREES_TO_RADIANS(degrees));
}

static inline void Matrix3DSetXRotationUsingRadians(Matrix3D mat, GLfloat rad){
	mat[5] = cosf(rad);
	mat[6] = -sinf(rad);
	mat[9] = -mat[6];
	mat[10] = mat[5];
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[7] = mat[8] = 0.0f;
	mat[11] = mat[12] = mat[13] = mat[14] = 0.0f;
	mat[0] = mat[15] = 1.0f;
}

static inline void Matrix3DSetXRotationUsingDegrees(Matrix3D mat, GLfloat degrees){
	Matrix3DSetXRotationUsingRadians(mat, DEGREES_TO_RADIANS(degrees));
}

static inline void Matrix3DSetRotationByRadians(Matrix3D mat, GLfloat rad, Vector3D vec){
	GLfloat mag = sqrtf((vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z));
	if(mag == 0.0f){
		vec.x = 1.0f;
		vec.y = 0.0f;
		vec.z = 0.0f;
	}else if(mag != 1.0f){
		vec.x /= mag;
		vec.y /= mag;
		vec.z /= mag;
	}
	GLfloat c = cosf(rad);
	GLfloat s = sinf(rad);
	mat[3] = mat[7] = mat[11] = 0.0f;
	mat[12] = mat[13] = mat[14] = 0.0f;
	mat[15] = 1.0f;
	
	mat[0] = (vec.x * vec.x) * (1-c) + c;
	mat[1] = (vec.x * vec.y) * (1-c) + (vec.z * s);
	mat[2] = (vec.x * vec.z) * (1-c) - (vec.y * s);
	
	mat[4] = (vec.y * vec.x) * (1-c) - (vec.z * s);
	mat[5] = (vec.y * vec.y) * (1-c) + c;
	mat[6] = (vec.y * vec.z) * (1-c) + (vec.x * s);
	
	mat[8] = (vec.z * vec.x) * (1-c) + (vec.y * s);
	mat[9] = (vec.z * vec.y) * (1-c) - (vec.x * s);
	mat[10] = (vec.z * vec.z)* (1-c) + c;
}

static inline void Matrix3DSetRotationByDegrees(Matrix3D mat, GLfloat deg, Vector3D vec){
	Matrix3DSetRotationByRadians(mat, DEGREES_TO_RADIANS(deg), vec);
}

static inline void Matrix3DMultiply(Matrix3D m1, Matrix3D m2, Matrix3D res){
	res[0] = m1[0] * m2[0] + m1[4] * m2[1] + m1[8] * m2[2] + m1[12] * m2[3];
	res[1] = m1[1] * m2[0] + m1[5] * m2[1] + m1[9] * m2[2] + m1[13] * m2[3];
	res[2] = m1[2] * m2[0] + m1[6] * m2[1] + m1[10] * m2[2] + m1[14] * m2[3];
	res[3] = m1[3] * m2[0] + m1[7] * m2[1] + m1[11] * m2[2] + m1[15] * m2[3];
	
	res[4] = m1[0] * m2[4] + m1[4] * m2[5] + m1[8] * m2[6] + m1[12] * m2[7];
	res[5] = m1[1] * m2[4] + m1[5] * m2[5] + m1[9] * m2[6] + m1[13] * m2[7];
	res[6] = m1[2] * m2[4] + m1[6] * m2[5] + m1[10] * m2[6] + m1[14] * m2[7];
	res[7] = m1[3] * m2[4] + m1[7] * m2[5] + m1[11] * m2[6] + m1[15] * m2[7];
	
	res[8] = m1[0] * m2[8] + m1[4] * m2[9] + m1[8] * m2[10] + m1[12] * m2[11];
	res[9] = m1[1] * m2[8] + m1[5] * m2[9] + m1[9] * m2[10] + m1[13] * m2[11];
	res[10] = m1[2] * m2[8] + m1[6] * m2[9] + m1[10] * m2[10] + m1[14] * m2[11];
	res[11] = m1[3] * m2[8] + m1[7] * m2[9] + m1[11] * m2[10] + m1[15] * m2[11];
	
	res[12] = m1[0] * m2[12] + m1[4] * m2[13] + m1[8] * m2[14] + m1[12] * m2[15];
	res[13] = m1[1] * m2[12] + m1[5] * m2[13] + m1[9] * m2[14] + m1[13] * m2[15];
	res[14] = m1[2] * m2[12] + m1[6] * m2[13] + m1[10] * m2[14] + m1[14] * m2[15];
	res[15] = m1[3] * m2[12] + m1[7] * m2[13] + m1[11] * m2[14] + m1[15] * m2[15];	
}

static inline void Matrix3DSetOrthoProjection(Matrix3D mat, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far){
	mat[1] = mat[2] = mat[3] = mat[4] = mat[6] = 0.0f;
	mat[7] = mat[8] = mat[9] = mat[11] = 0.0f;
	mat[0] = 2.0f / (right - left);
	mat[5] = 2.0f / (top - bottom);
	mat[10] = -2.0f / (far - near);
	mat[12] = (right + left) / (right - left);
	mat[13] = (top + bottom) / (top - bottom);
	mat[14] = (far + near) / (far - near);
	mat[15] = 1.0f;
}

static inline void Matrix3DSetFrustumProjection(Matrix3D mat, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far){
	mat[1] = mat[2] = mat[3] = mat[4] = 0.0f;
	mat[6] = mat[7] = mat[12] = mat[13] = mat[15] = 0.0f;
	mat[0] = 2.0f * near / (right - left);
	mat[5] = 2.0f * near / (top - bottom);
	mat[8] = (right + left) / (right - left);
	mat[9] = (top + bottom) / (top - bottom);
	mat[10] = -(far + near) / (far - near);
	mat[11] = -1.0f;
	mat[14] = -(2.0f * far * near) / (far - near);
}

static inline void Matrix3DSetPerspectiveProjectionWithFieldOfView(Matrix3D mat, GLfloat fov, GLfloat near, GLfloat far, GLfloat aspect){
	GLfloat size = near * tanf(DEGREES_TO_RADIANS(fov) / 2.0f);
	Matrix3DSetFrustumProjection(mat, -size, size, -size / aspect, size / aspect, near, far);
}