//
//  Shader.fsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//uniform samplerCube texture;

//varying highp vec4 pos;

void main(){
	//gl_FragColor = textureCube(texture, vec3(pos));
	//gl_FragColor.a = 1.0;
	gl_FragColor = vec4(0.0, 1.0, 0.5, 1.0);
	//gl_FragColor = vec4(1.0, 0.1, 0.5, 1.0);
}
