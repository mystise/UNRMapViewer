//
//  Shader.vsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying lowp vec4 colorVarying;

uniform float translate;

void main(){
	gl_Position = position;
	gl_Position.y += sin(translate) / 2.0;

	colorVarying = color;
}
