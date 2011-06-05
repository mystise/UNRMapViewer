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

class Camera{
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
	
	virtual Camera &moveRel(Vector3D disp){
		float newX, newY, newZ;
		Vector3D right;
		fix(right);
		newX = disp * right;
		newY = disp * up;
		newZ = disp * look;
		Vector3D newDisp = Vector3D(newX, newY, newZ);
		pos += newDisp;
		return *this;
	}
	
	Camera &fix(Vector3D &right){
		look.normalize();
		
		right = up ^ look;
		up = look ^ right;
		
		right.normalize();
		up.normalize();
		return *this;
	}
	
	virtual Matrix3D glData(){
		Matrix3D mat;
		mat.translate(-pos);
		
		Vector3D right;
		fix(right);
		
		mat[0] = right.x;
		mat[1] = right.y;
		mat[2] = right.z;
		
		mat[4] = up.x;
		mat[5] = up.y;
		mat[6] = up.z;
		
		mat[8] = look.x;
		mat[9] = look.y;
		mat[10] = look.z;
		
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
	
	/*virtual FPSCamera &moveRel(Vector3D disp){
		float newX, newY, newZ;
		Vector3D right;
		fix(right);
		newX = disp * right;
		newY = disp * up;
		newZ = disp * look;
		Vector3D newDisp = Vector3D(newX, newY, newZ);
		pos += newDisp;
		return *this;
	}*/
	
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
	
	virtual Matrix3D glData(){
		return ((Camera)*this).glData().rotateY(rotY).rotateX(rotX);
	}
	
protected:
	float rotX, rotY, clamp;
};