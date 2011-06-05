//
//  Matrix3D.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <math.h>

namespace Vector{
	struct Vector4D{
	public:
		Vector4D(): x(0), y(0), z(0), w(0){
			
		}
		
		Vector4D(float x, float y, float z, float w): x(x), y(y), z(z), w(w){
			
		}
		
		float magnitude(){
			return sqrtf(x*x + y*y + z*z + w*w);
		}
		
		const Vector4D operator +(const Vector4D &vec) const{
			return Vector4D(x + vec.x, y + vec.y, z + vec.z, w + vec.w);
		}
		
		const Vector4D operator -(const Vector4D &vec) const{
			return Vector4D(x - vec.x, y - vec.y, z - vec.z, w - vec.w);
		}
		
		const Vector4D operator *(float scale) const{
			return Vector4D(x*scale, y*scale, z*scale, w*scale);
		}
		
		const Vector4D operator /(float scale) const{
			return Vector4D(x/scale, y/scale, z/scale, w/scale);
		}
		
		Vector4D operator -() const{
			return Vector4D(-x, -y, -z, -w);
		}
		
		Vector4D &operator +=(const Vector4D &vec){
			*this = *this + vec;
			return *this;
		}
		
		Vector4D &operator -=(const Vector4D &vec){
			*this = *this - vec;
			return *this;
		}
		
		Vector4D &operator *=(float scale){
			*this = *this * scale;
			return *this;
		}
		
		Vector4D &operator /=(float scale){
			*this = *this / scale;
			return *this;
		}
		
		Vector4D &normalize(){
			*this /= magnitude();
			return *this;
		}
		
		float x, y, z, w;
	};
	
	struct Vector3D{
	public:
		Vector3D(): x(0), y(0), z(0){
			
		}
		
		Vector3D(float x, float y, float z): x(x), y(y), z(z){
			
		}
		
		float magnitude(){
			return sqrtf(x*x + y*y + z*z);
		}
		
		const Vector3D operator +(const Vector3D &vec) const{
			return Vector3D(x + vec.x, y + vec.y, z + vec.z);
		}
		
		const Vector3D operator -(const Vector3D &vec) const{
			return Vector3D(x - vec.x, y - vec.y, z - vec.z);
		}
		
		const Vector3D operator *(float scale) const{
			return Vector3D(x*scale, y*scale, z*scale);
		}
		
		const float operator *(const Vector3D &vec) const{
			return (x*vec.x + y*vec.y + z*vec.z);
		}
		
		const Vector3D operator ^(const Vector3D &vec) const{
			return Vector3D(y*vec.z - z*vec.y, z*vec.x - x*vec.z, x*vec.y - y*vec.x);
		}
		
		const Vector3D operator /(float scale) const{
			return Vector3D(x/scale, y/scale, z/scale);
		}
		
		Vector3D operator -(){
			return Vector3D(-x, -y, -z);
		}
		
		Vector3D &operator +=(const Vector3D &vec){
			*this = *this + vec;
			return *this;
		}
		
		Vector3D &operator -=(const Vector3D &vec){
			*this = *this - vec;
			return *this;
		}
		
		Vector3D &operator *=(float scale){
			*this = *this * scale;
			return *this;
		}
		
		Vector3D &operator /=(float scale){
			*this = *this / scale;
			return *this;
		}
		
		Vector3D &normalize(){
			*this /= magnitude();
			return *this;
		}
		
		float x, y, z;
	};
	
	struct Vector2D{
	public:
		Vector2D(): x(0), y(0){
			
		}
		
		Vector2D(float x, float y): x(x), y(y){
			
		}
		
		Vector2D(CGPoint point): x(point.x), y(point.y){
			
		}
		
		float magnitude(){
			return sqrtf(x*x + y*y);
		}
		
		const Vector2D operator +(const Vector2D &vec) const{
			return Vector2D(x + vec.x, y + vec.y);
		}
		
		const Vector2D operator -(const Vector2D &vec) const{
			return Vector2D(x - vec.x, y - vec.y);
		}
		
		const Vector2D operator *(float scale) const{
			return Vector2D(x*scale, y*scale);
		}
		
		const Vector2D operator /(float scale) const{
			return Vector2D(x/scale, y/scale);
		}
		
		const float operator *(const Vector2D &vec) const{
			return (x*vec.x + y*vec.y);
		}
		
		Vector2D operator -(){
			return Vector2D(-x, -y);
		}
		
		Vector2D &operator +=(const Vector2D &vec){
			*this = *this + vec;
			return *this;
		}
		
		Vector2D &operator -=(const Vector2D &vec){
			*this = *this - vec;
			return *this;
		}
		
		Vector2D &operator *=(float scale){
			*this = *this * scale;
			return *this;
		}
		
		Vector2D &operator /=(float scale){
			*this = *this / scale;
			return *this;
		}
		
		Vector2D &normalize(){
			*this /= magnitude();
			return *this;
		}
		
		float x, y;
	};
}