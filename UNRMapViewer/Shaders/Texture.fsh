//
//  Shader.fsh
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

uniform sampler2D texture;
uniform sampler2D lightmap;

varying mediump vec2 texCoord;
varying lowp vec2 lightCoord;

void main(){
	gl_FragColor = 2.0*texture2D(lightmap, lightCoord)*texture2D(texture, texCoord);
	//gl_FragColor = texture2D(lightmap, lightCoord);
	//gl_FragColor = texture2D(texture, texCoord);
}
