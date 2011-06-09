//
//  GLCamera.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Vector.h"
using Vector::Vector3D;

#import "Matrix.h"
using Matrix::Matrix3D;

class FPSCamera{
public:
	FPSCamera(): rotY(0.0f), rotX(0.0f), clamp(89.0f), pos(0.0f, 0.0f, 0.0f), up(0.0f, 1.0f, 0.0f), look(0.0f, 0.0f, -1.0f), right(1.0f, 0.0f, 0.0f){
		
	}
	
	FPSCamera &move(Vector3D vec){
		pos += vec;
		return *this;
	}
	
	FPSCamera &moveTo(Vector3D vec){
		pos = vec;
		return *this;
	}
	
	FPSCamera &lookAt(Vector3D vec){
		look = vec - pos;
		look.normalize();
		return *this;
	}
	
	FPSCamera &lookTo(Vector3D vec){
		look = vec;
		look.normalize();
		return *this;
	}
	
	FPSCamera &setUp(Vector3D vec){
		up = vec;
		return *this;
	}
	
	FPSCamera &rotate(float x, float y){
		rotX += x;
		rotY += y;
		if(rotX > clamp){
			rotX = clamp;
		}else if(rotX < -clamp){
			rotX = -clamp;
		}
		return *this;
	}
	
	FPSCamera &rotateTo(float x, float y){
		rotX = x;
		rotY = y;
		if(rotX > clamp){
			rotX = clamp;
		}else if(rotX < -clamp){
			rotX = -clamp;
		}
		return *this;
	}
	
	FPSCamera &rotateX(float x){
		rotX += x;
		if(rotX > clamp){
			rotX = clamp;
		}else if(rotX < -clamp){
			rotX = -clamp;
		}
		return *this;
	}
	
	FPSCamera &rotateY(float y){
		rotY += y;
		return *this;
	}
	
	FPSCamera &moveRel(Vector3D vec){
		Matrix3D mat;
		mat.translate(-vec.x, -vec.y, -vec.z);
		
		Matrix3D mat2;
		
		{
			Matrix3D mat;
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
		
		pos += Vector3D(mat[12], mat[13], mat[14]);
		
		return *this;
	}
	
	Matrix3D glData(){
		Matrix3D mat;
		mat.rotateX(-rotX);
		mat.rotateY(-rotY);
		
		Matrix3D mat2;
		
		prepare();
		
		mat2[0] = right.x;
		mat2[4] = right.y;
		mat2[8] = right.z;
		
		mat2[1] = up.x;
		mat2[5] = up.y;
		mat2[9] = up.z;
		
		mat2[2] = -look.x;
		mat2[6] = -look.y;
		mat2[10] = -look.z;
		
		Matrix3D mat3;
		mat3.translate(-pos.x, -pos.y, -pos.z);
		
		Matrix3D retMat;
		retMat = mat * mat2 * mat3;
		
		return retMat;
	}
protected:
	void prepare(){
		right = look ^ up;
		up = right ^ look;
		
		right.normalize();
		up.normalize();
	}
	
	float rotY, rotX, clamp;
	Vector3D pos, up, look, right;
};

/*class Camera{
public:
	Camera(): pos(), up(), look(){
		
	}
	
	Camera(Vector3D newPos, Vector3D newUp, Vector3D newLook): pos(newPos), up(newUp), look(newLook){
		
	}
	
	Camera &moveTo(Vector3D newPos){
		pos = newPos;
		return *this;
	}
	
	Camera &move(Vector3D disp){
		pos += disp;
		return *this;
	}
	
	Camera &lookTo(Vector3D newLook){
		look = newLook;
		return *this;
	}
	
	Camera &lookAt(Vector3D newLook){
		look = newLook - pos;
		return *this;
	}
	
	Camera &setUp(Vector3D newUp){
		up = newUp;
		return *this;
	}
	
	Camera &moveRel(Vector3D disp){
		Matrix3D mat = glData();
		mat.translate(-disp.x, -disp.y, -disp.z);
		Vector3D newDisp = Vector3D(mat[12], mat[13], mat[14]);
		pos = newDisp;
		return *this;
	}
	
	Camera &fix(Vector3D &right){
		look.normalize();
		
		right = look ^ up;
		up = right ^ look;
		
		right.normalize();
		up.normalize();
		return *this;
	}
	
	Matrix3D glData(){
		Matrix3D mat;
		
		Vector3D right;
		fix(right);
		
		mat[0] = right.x;
		mat[4] = right.y;
		mat[8] = right.z;
		
		mat[1] = up.x;
		mat[5] = up.y;
		mat[9] = up.z;
		
		mat[2] = -look.x;
		mat[6] = -look.y;
		mat[10] = -look.z;
		
		mat.translate(-pos);
		
		return mat;
	}
	
protected:
	Vector3D pos, up, look;
};

class FPSCamera: public Camera{
public:
	FPSCamera(): rotX(0.0f), rotY(0.0f), clamp(89.0f){
		
	}
	
	FPSCamera(float newX, float newY, float newClamp): rotX(newX), rotY(newY), clamp(newClamp){
		
	}
	
	*FPSCamera &moveRel(Vector3D disp){
		//newx = disp . x vec = disp.x*x.x + disp.y*x.y + disp.z*x.z
		//newy = disp . y vec
		//newz = disp . z vec
		
		Matrix3D mat = glData();
		mat.translate(disp.x, disp.y, disp.z);
		Vector3D newDisp = Vector3D(mat[12], mat[13], mat[14]);
		pos += newDisp;
		return *this;
	}*
	
	FPSCamera &rotateTo(float x, float y){
		rotX = x;
		rotY = y;
		
		if(rotX > clamp){
			rotX = clamp;
		}
		if(rotX < -clamp){
			rotX = -clamp;
		}
		
		return *this;
	}
	
	FPSCamera &rotate(float x, float y){
		rotX += x;
		rotY += y;
		
		if(rotX > clamp){
			rotX = clamp;
		}
		if(rotX < -clamp){
			rotX = -clamp;
		}
		
		return *this;
	}
	
	Matrix3D glData(){
		Matrix3D mat;
		
		mat.rotateX(-rotX);
		mat.rotateY(-rotY);
		mat *= Camera::glData();
		
		return mat;
	}
	
protected:
	float rotX, rotY, clamp;
};*/