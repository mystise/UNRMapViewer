//
//  Shader.vsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

uniform mat4 modelViewProjection;

attribute vec4 position;

void main(){
	gl_Position = modelViewProjection*position;
}