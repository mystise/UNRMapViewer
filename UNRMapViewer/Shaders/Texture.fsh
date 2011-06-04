//
//  Shader.fsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

uniform sampler2D texture;

varying highp vec2 texCoord;

void main(){
	//gl_FragColor = vec4(0.0, 1.0, 0.5, 0.0);
	gl_FragColor = texture2D(texture, texCoord);
}
