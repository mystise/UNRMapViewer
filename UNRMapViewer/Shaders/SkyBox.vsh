//
//  Shader.vsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

uniform mat4 modelViewProjection;
//uniform vec4 camPos;

attribute vec4 position;

//varying vec4 pos;

void main(){
	gl_Position = modelViewProjection*position;
	//pos = normalize(position + camPos);
	//pos = position+camPos;
}
