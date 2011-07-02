//
//  Matrix3D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define DEGREES_TO_RADIANS(x) ((x) / 180.0f * M_PI)
#define RADIANS_TO_DEGREES(x) ((x) / M_PI * 180.0f)

#error Matrix3D c++ class is deprecated. Don't use.

#import <math.h>

#import "Vector.h"
using Vector::Vector3D;
using Vector::Vector4D;

namespace Matrix{
	class Matrix3D{
	public:
		Matrix3D(): m(){
			m[0] = 1.0f;
			m[1] = m[2] = m[3] = m[4] = 0.0f;
			m[5] = 1.0f;
			m[6] = m[7] = m[8] = m[9] = 0.0f;
			m[10] = 1.0f;
			m[11] = m[12] = m[13] = m[14] = 0.0f;
			m[15] = 1.0f;
		}
		
		Matrix3D(float diag): m(){
			m[0] = diag;
			m[1] = m[2] = m[3] = m[4] = 0.0f;
			m[5] = diag;
			m[6] = m[7] = m[8] = m[9] = 0.0f;
			m[10] = diag;
			m[11] = m[12] = m[13] = m[14] = 0.0f;
			m[15] = diag;
		}
		
		inline Matrix3D &identity(){
			m[0] = 1.0f;
			m[1] = m[2] = m[3] = m[4] = 0.0f;
			m[5] = 1.0f;
			m[6] = m[7] = m[8] = m[9] = 0.0f;
			m[10] = 1.0f;
			m[11] = m[12] = m[13] = m[14] = 0.0f;
			m[15] = 1.0f;
			return *this;
		}
		
		inline Matrix3D &transpose(){
			float temp[16];
			for(int i = 0; i < 4; i++){
				for(int j = 0; j < 4; j++){
					temp[j*4 + i] = m[i*4 + j];
				}
			}
			for(int i = 0; i < 16; i++){
				m[i] = temp[i];
			}
			return *this;
		}
		
		inline Matrix3D operator *(const Matrix3D &mat) const{
			Matrix3D res;
			res[0] = m[0]  * mat[0]  + m[4] * mat[1]  + m[8]  * mat[2]  + m[12] * mat[3];
			res[1] = m[1]  * mat[0]  + m[5] * mat[1]  + m[9]  * mat[2]  + m[13] * mat[3];
			res[2] = m[2]  * mat[0]  + m[6] * mat[1]  + m[10] * mat[2]  + m[14] * mat[3];
			res[3] = m[3]  * mat[0]  + m[7] * mat[1]  + m[11] * mat[2]  + m[15] * mat[3];
			
			res[4] = m[0]  * mat[4]  + m[4] * mat[5]  + m[8]  * mat[6]  + m[12] * mat[7];
			res[5] = m[1]  * mat[4]  + m[5] * mat[5]  + m[9]  * mat[6]  + m[13] * mat[7];
			res[6] = m[2]  * mat[4]  + m[6] * mat[5]  + m[10] * mat[6]  + m[14] * mat[7];
			res[7] = m[3]  * mat[4]  + m[7] * mat[5]  + m[11] * mat[6]  + m[15] * mat[7];
			
			res[8] = m[0]  * mat[8]  + m[4] * mat[9]  + m[8]  * mat[10] + m[12] * mat[11];
			res[9] = m[1]  * mat[8]  + m[5] * mat[9]  + m[9]  * mat[10] + m[13] * mat[11];
			res[10] = m[2] * mat[8]  + m[6] * mat[9]  + m[10] * mat[10] + m[14] * mat[11];
			res[11] = m[3] * mat[8]  + m[7] * mat[9]  + m[11] * mat[10] + m[15] * mat[11];
			
			res[12] = m[0] * mat[12] + m[4] * mat[13] + m[8]  * mat[14] + m[12] * mat[15];
			res[13] = m[1] * mat[12] + m[5] * mat[13] + m[9]  * mat[14] + m[13] * mat[15];
			res[14] = m[2] * mat[12] + m[6] * mat[13] + m[10] * mat[14] + m[14] * mat[15];
			res[15] = m[3] * mat[12] + m[7] * mat[13] + m[11] * mat[14] + m[15] * mat[15];
			return res;
		}
		
		inline const Matrix3D &operator *=(const Matrix3D &mat){
			*this = *this * mat;
			return *this;
		}
		
		inline float &operator [](int index){
			if(index < 16){
				return m[index];
			}
			//error!!!
			return m[0];
		}
		
		inline float operator [](int index) const{
			if(index < 16){
				return m[index];
			}
			//error!!!
			return 0.0f;
		}
		
		inline Matrix3D &rotateX(float degrees){
			Matrix3D mat;
			float rad = DEGREES_TO_RADIANS(degrees);
			
			mat[5] = cosf(rad);
			mat[6] = -sinf(rad);
			mat[9] = -mat[6];
			mat[10] = mat[5];
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &rotateY(float degrees){
			Matrix3D mat;
			float rad = DEGREES_TO_RADIANS(degrees);
			
			mat[0] = cosf(rad);
			mat[2] = sinf(rad);
			mat[8] = -mat[2];
			mat[10] = mat[0];
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &rotateZ(float degrees){
			Matrix3D mat;
			float rad = DEGREES_TO_RADIANS(degrees);
			
			mat[0] = cosf(rad);
			mat[1] = sinf(rad);
			mat[4] = -mat[1];
			mat[5] = mat[0];
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &rotate(float degrees, float x, float y, float z){
			Matrix3D mat;
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
			
			mat[0] = (x * x) * (1-c) + c;
			mat[1] = (x * y) * (1-c) + (z * s);
			mat[2] = (x * z) * (1-c) - (y * s);
			
			mat[4] = (y * x) * (1-c) - (z * s);
			mat[5] = (y * y) * (1-c) + c;
			mat[6] = (y * z) * (1-c) + (x * s);
			
			mat[8] = (z * x) * (1-c) + (y * s);
			mat[9] = (z * y) * (1-c) - (x * s);
			mat[10] = (z * z)* (1-c) + c;
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &rotate(float degrees, Vector3D vec){
			return rotate(degrees, vec.x, vec.y, vec.z);
		}
		
		inline Matrix3D &translate(float x, float y, float z){
			Matrix3D mat;
			
			mat[12] = x;
			mat[13] = y;
			mat[14] = z;
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &translate(Vector3D vec){
			return translate(vec.x, vec.y, vec.z);
		}
		
		inline Matrix3D &scale(float x, float y, float z){
			Matrix3D mat;
			
			mat[0] = x;
			mat[5] = y;
			mat[10] = z;
			
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &scale(Vector3D vec){
			return scale(vec.x, vec.y, vec.z);
		}
		
		inline Matrix3D &uniformScale(float s){
			this->scale(s, s, s);
			return *this;
		}
		
		inline float *glData(){
			return m;
		}
		
		inline Matrix3D &orthographic(float left, float right, float bottom, float top, float near, float far){
			Matrix3D mat;
			mat[0] = 2.0f / (right - left);
			mat[5] = 2.0f / (top - bottom);
			mat[10] = -2.0f / (far - near);
			mat[12] = (right + left) / (right - left);
			mat[13] = (top + bottom) / (top - bottom);
			mat[14] = (far + near) / (far - near);
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &frustum(float left, float right, float bottom, float top, float near, float far){
			Matrix3D mat;
			mat[0] = 2.0f * near / (right - left);
			mat[5] = 2.0f * near / (top - bottom);
			mat[8] = (right + left) / (right - left);
			mat[9] = (top + bottom) / (top - bottom);
			mat[10] = -(far + near) / (far - near);
			mat[11] = -1.0f;
			mat[14] = -(2.0f * far * near) / (far - near);
			mat[15] = 0.0f;
			*this *= mat;
			return *this;
		}
		
		inline Matrix3D &perspective(float fov, float near, float far, float aspect){
			float size = near * tanf(DEGREES_TO_RADIANS(fov) / 2.0f);
			frustum(-size, size, -size / aspect, size / aspect, near, far);
			return *this;
		}
		
	private:
		float m[16];
	};
}