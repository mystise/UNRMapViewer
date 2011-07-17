//
//  UNRTextureExporter.m
//  UNRTextureExporter
//
//  Created by Adalynn Dudney on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRTexture.h"
#import "UNRProperty.h"
#import "UNRExport.h"
#import "UNRNode.h"

#define USE_32_Bit 1

#if USE_32_Bit
typedef struct{
	Byte r, g, b, a;
}color;

color ColorCreate(Byte r, Byte g, Byte b, Byte a){
	color retCol;
	retCol.r = r;
	retCol.g = g;
	retCol.b = b;
	retCol.a = a;
	return retCol;
}

color ColorAdd(color col1, color col2){
	color retCol;
	
	int added = col1.r + col2.r;
	if(added > 0xFF){
		added = 0xFF;
	}
	retCol.r = added;
	
	added = col1.g + col2.g;
	if(added > 0xFF){
		added = 0xFF;
	}
	retCol.g = added;
	
	added = col1.b + col2.b;
	if(added > 0xFF){
		added = 0xFF;
	}
	retCol.b = added;
	
	retCol.a = 0xFF;
	
	return retCol;
}
#else
#pragma pack(push)
#pragma pack(2)
typedef struct{
	union{
		unsigned short color;
		struct{
			Byte a:1, b:5, g:5, r:5;
		};
	};
}color;
#pragma pack(pop)

color ColorCreate(float r, float g, float b, float a){
	color retCol = {0};
	retCol.r = r*31.0f/255.0f;
	retCol.g = g*31.0f/255.0f;
	retCol.b = b*31.0f/255.0f;
	retCol.a = a/255.0f;
	return retCol;
}

color ColorAdd(color col1, color col2){
	color retCol;
	
	float div = 1.0f;
	
	Byte red = col1.r + col2.r;
	if(red > 31){
		float div2 = red/31.0f;
		if(div2 > div){
			div = div2;
		}
	}
	
	Byte green = col1.g + col2.g;
	if(green > 31){
		float div2 = green/31.0f;
		if(div2 > div){
			div = div2;
		}
	}
	
	Byte blue = col1.b + col2.b;
	if(blue > 31){
		float div2 = blue/31.0f;
		if(div2 > div){
			div = div2;
		}
	}
	
	retCol.r = red/div;
	retCol.g = green/div;
	retCol.b = blue/div;
	
	retCol.a = 1;
	
	return retCol;
}
#endif

@implementation UNRTexture

@synthesize width = width_, height = height_, glTex = glTex_;
@synthesize textureData = textureData_;

+ (id)textureWithObject:(NSMutableDictionary *)obj attributes:(NSDictionary *)attrib{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		NSArray *palette = nil;
		int format = 0;
		BOOL masked = [[attrib valueForKey:@"masked"] boolValue];
		int startMip = [[attrib valueForKey:@"startMip"] intValue];
		BOOL noSmooth = [[attrib valueForKey:@"noSmooth"] boolValue];
		int correctMipCount = 0;
		
		{
			NSMutableDictionary *props = [obj valueForKey:@"props"];
			UNRProperty *formatProp = [props valueForKey:@"Format"];
			format = [formatProp.manager loadByte];
			
			UNRProperty *paletteProp = [props valueForKey:@"Palette"];
			UNRExport *paletteObj = (UNRExport *)paletteProp.object;
			if([paletteObj isKindOfClass:[UNRImport class]]){
				UNRImport *obj2 = (UNRImport *)paletteObj;
				paletteObj = obj2.obj;
			}
			palette = [paletteObj.objectData valueForKey:@"palette"];
			
			UNRProperty *ubit = [props valueForKey:@"UBits"];
			Byte ubits = [ubit.manager loadByte];
			if(ubits > correctMipCount){
				correctMipCount = ubits;
			}
			
			UNRProperty *vbit = [props valueForKey:@"VBits"];
			Byte vbits = [vbit.manager loadByte];
			if(vbits > correctMipCount){
				correctMipCount = vbits;
			}
		}
		
		if(startMip >= correctMipCount){
			startMip = correctMipCount-1;
		}
		if(startMip >= [[obj valueForKey:@"mipMapLevels"] count]){
			startMip = [[obj valueForKey:@"mipMapLevels"] count]-1;
		}
		if(startMip < 0){
			startMip = 0;
		}
		
		GLuint glTex = 0;
		glGenTextures(1, &glTex);
		tex.glTex = glTex;
		glBindTexture(GL_TEXTURE_2D, tex.glTex);
		
		tex.width = [[[[obj valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"width"] intValue];
		tex.height = [[[[obj valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"height"] intValue];
		
		GLenum magMode = GL_LINEAR;
		if(noSmooth){
			magMode = GL_NEAREST;
		}
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magMode);
		
		GLenum minMode = GL_LINEAR_MIPMAP_NEAREST;
		if(noSmooth){
			minMode = GL_NEAREST_MIPMAP_NEAREST;
		}
		if([[obj valueForKey:@"mipMapCount"] intValue] != correctMipCount){ //if mipMapping is disabled for this texture
			minMode -= 0x100; //disable mipmapping
		}
		
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minMode);
		
		for(int i = startMip; i < [[obj valueForKey:@"mipMapCount"] intValue]; i++){
			NSMutableDictionary *texLevel = [[obj valueForKey:@"mipMapLevels"] objectAtIndex:i];
			DataManager *manager = [[DataManager alloc] initWithFileData:[texLevel valueForKey:@"mipMap"]];
			
			int levelWidth = [[texLevel valueForKey:@"width"] intValue];
			int levelHeight = [[texLevel valueForKey:@"height"] intValue];
			
			color *glTexData = calloc(levelWidth*levelHeight, sizeof(color));
			//stored width first
			
			if(format == 0){ //paletted
				//TODO: do this using Core Graphics ?
				for(int i = 0; i < levelHeight; i++){
					for(int j = 0; j < levelWidth; j++){
						Byte index = [manager loadByte];
						NSNumber *colorR = [[palette objectAtIndex:index] valueForKey:@"red"];
						NSNumber *colorG = [[palette objectAtIndex:index] valueForKey:@"green"];
						NSNumber *colorB = [[palette objectAtIndex:index] valueForKey:@"blue"];
						NSNumber *colorA = [[palette objectAtIndex:index] valueForKey:@"alpha"];
						if(masked == YES){
							if(index == 0){
								colorA = [NSNumber numberWithUnsignedChar:0x00];
							}else{
								colorA = [NSNumber numberWithUnsignedChar:0xFF];
							}
						}
						//(color){[colorR unsignedCharValue]*63/255, [colorG unsignedCharValue]*63/255, [colorB unsignedCharValue]*63/255, [colorA unsignedCharValue]*1/255}
						glTexData[i*levelWidth + j] = ColorCreate([colorR unsignedCharValue], [colorG unsignedCharValue], [colorB unsignedCharValue], [colorA unsignedCharValue]);
					}
				}
			}else{
				NSLog(@"Un-paletted textures are currently unsupported.\n");
			}
			[manager release];
			
			//glPixelStorei(GL_PACK_ALIGNMENT, 2);
			//glPixelStorei(GL_UNPACK_ALIGNMENT, 2);
			
#if USE_32_Bit
			glTexImage2D(GL_TEXTURE_2D, i-startMip, GL_RGBA, levelWidth, levelHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, glTexData);
#else
			glTexImage2D(GL_TEXTURE_2D, i-startMip, GL_RGBA, levelWidth, levelHeight, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, glTexData);
#endif
			
			free(glTexData);
		}
	}
	return [tex autorelease];
}

int roundToNext8(int input){
	int retVal;
	if(input % 8 == 0){
		retVal = input;
	}else{
		retVal = input + (8-input%8);
	}
	return retVal;
}

color hsvToRGB(unsigned int inH, unsigned int inS, unsigned int inV) {
	color col = {0};
	float f, p, q, t;
	float h, s, v;
	float r = 0.0f, g = 0.0f, b = 0.0f;
	int i;
	if(inS == 0xFF){
		col = ColorCreate(inV, inV, inV, 0xFF);
	}else{
		h = (float)inH/0xFF * 360.0f;
		s = 1.0f - (float)inS/0xFF;
		v = (float)inV/0xFF;
		if(h == 360.0f){
			h = 0.0f;
		}
		h /= 60.0f;
		i = floor(h);						//i = point of the hexagon
		f = h-i;							//float = distance from point of hexagon
		p = v * (1.0 - s);					//p = value * (1.0 - saturation)
		q = v * (1.0 - (s * f));			//q = value * (1.0 - saturation*float)
		t = v * (1.0 - (s * (1.0 - f)));	//t = value * (1.0 - saturation*(1.0 - float))
		if(i == 0){
			r = v;
			g = t;
			b = p;
		}else if(i == 1){
			r = q;
			g = v;
			b = p;
		}else if(i == 2){
			r = p;
			g = v;
			b = t;
		}else if(i == 3){
			r = p;
			g = q;
			b = v;
		}else if(i == 4){
			r = t;
			g = p;
			b = v;
		}else if(i == 5){
			r = v;
			g = p;
			b = q;
		}
		col = ColorCreate(r*255, g*255, b*255, 0xFF);
	}
	return col;
}

void printLightType(int lType){
	switch(lType){
		case 0:
			printf("LE_None");
			break;
		case 1:
			printf("LE_TorchWaver");
			break;
		case 2:
			printf("LE_FireWaver");
			break;
		case 3:
			printf("LE_WateryShimmer");
			break;
		case 4:
			printf("LE_SearchLight");
			break;
		case 5:
			printf("LE_SlowWave");
			break;
		case 6:
			printf("LE_FastWave");
			break;
		case 7:
			printf("LE_CloudCast");
			break;
		case 8:
			printf("LE_StaticSpot");
			break;
		case 9:
			printf("LE_Shock");
			break;
		case 10:
			printf("LE_Disco");
			break;
		case 11:
			printf("LE_Warp");
			break;
		case 12:
			printf("LE_Spotlight");
			break;
		case 13:
			printf("LE_NonIncidence");
			break;
		case 14:
			printf("LE_Shell");
			break;
		case 15:
			printf("LE_OmniBumpMap");
			break;
		case 16:
			printf("LE_Interference");
			break;
		case 17:
			printf("LE_Cylinder");
			break;
		case 18:
			printf("LE_Rotor");
			break;
		case 19:
			printf("LE_Unused");
			break;
		default:
			break;
	}
}

+ (id)textureWithLightMap:(NSMutableDictionary *)lightMap data:(NSMutableData *)data lights:(NSMutableArray *)lights node:(struct UNRNode *)node{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		tex.width = [[lightMap valueForKey:@"uClamp"] unsignedIntValue]; //width and height are not necessarily powers of two
		tex.height = [[lightMap valueForKey:@"vClamp"] unsignedIntValue];
		int dataOffset = [[lightMap valueForKey:@"dataOffset"] unsignedIntValue];
		
		Vector3D lightU = node->uVec;
		Vector3D lightV = node->vVec;
		Vector3D dx = Vector3DMultiply(Vector3DNormalize(lightU), 32.0f/Vector3DMagnitude(lightU));
		Vector3D dy = Vector3DMultiply(Vector3DNormalize(lightV), 32.0f/Vector3DMagnitude(lightV));
		
		GLuint texture;
		glGenTextures(1, &texture);
		tex.glTex = texture;
		glBindTexture(GL_TEXTURE_2D, tex.glTex);
		
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		if(nil == lightMap){
			tex.width = 1;
			tex.height = 1;
		}
		
        if(nil == lightMap && !(node->surfFlags & PF_NoShadows)) {
			//black!!!
			void *data = calloc(tex.width * tex.height, sizeof(color));
			//((color *)data)->g = 255;
			tex.textureData = [NSData dataWithBytesNoCopy:data
												   length:tex.width * tex.height * sizeof(color)];
			return [tex autorelease];
        }
		
		if(!(node->surfFlags & PF_NoShadows)){
			int iLightActors = [[lightMap valueForKey:@"iLightActors"] intValue];
			if(iLightActors != -1){
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
				
				NSMutableArray *mapLights = [NSMutableArray array];
				id light = [lights objectAtIndex:iLightActors];
				for(int i = 1; ![light isKindOfClass:[NSNull class]] && i+iLightActors < [lights count]; i++){
					if([mapLights count] > 0){
						if(light == [mapLights lastObject]){
							printf("Same!!!\n");
							continue;
						}
					}
					[mapLights addObject:light];
					light = [lights objectAtIndex:iLightActors+i];
				}
				
				int nextWidth = roundToNext8(tex.width);
				int lightCount = [mapLights count];
				int texSize = tex.height*nextWidth/8;
				int bytesToLoad = texSize*lightCount;
				if(bytesToLoad + dataOffset <= [data length]){
					
					Byte *coverage = calloc(tex.width*tex.height, sizeof(Byte));
					color *texDat = calloc(tex.width*tex.height, sizeof(color));
					
					Byte *rawDat;
					NSData *subDat = [data subdataWithRange:NSMakeRange(dataOffset, bytesToLoad)];
					rawDat = (Byte *)[subDat bytes];
					for(int y = 0; y < lightCount; y++){
						for(int i = 0; i < tex.height; i++){
							for(int j = 0; j < tex.width; j+=8){
								for(int x = 0; x < 8 && x+j < tex.width; x++){
									int rawIndex = i*nextWidth/8 + j/8 + y*texSize;
									int texIndex = i*tex.width + j+x;
									Byte newDat = ((rawDat[rawIndex]>>x)&0x01);
									
									coverage[texIndex] = newDat;
								}
							}
						}
						
						Byte hue = 0, saturation = 255, value = 64;
						int radius = 64;
						Vector3D lightPos;
						NSMutableArray *currentLight = [[[mapLights objectAtIndex:y] objectData] valueForKey:@"props"];
						{
							UNRProperty *brightProp = [currentLight valueForKey:@"LightBrightness"];
							if(brightProp){
								value = [brightProp.manager loadByte];
								brightProp.manager.curPos = 0;
							}
							
							UNRProperty *satProp = [currentLight valueForKey:@"LightSaturation"];
							if(satProp){
								saturation = [satProp.manager loadByte];
								satProp.manager.curPos = 0;
							}
							
							UNRProperty *hueProp = [currentLight valueForKey:@"LightHue"];
							if(hueProp){
								hue = [hueProp.manager loadByte];
								hueProp.manager.curPos = 0;
							}
							
							UNRProperty *radProp = [currentLight valueForKey:@"LightRadius"];
							if(radProp){
								radius = [radProp.manager loadByte];
								radProp.manager.curPos = 0;
							}
							
							UNRProperty *location = [currentLight valueForKey:@"Location"];
							lightPos.x = [location.manager loadFloat];
							lightPos.y = [location.manager loadFloat];
							lightPos.z = [location.manager loadFloat];
							location.manager.curPos = 0;
						}
						/*else if([prop.name.string isEqualToString:@"LightEffect"]){
						 printf("\t");
						 printLightType([manager loadByte]);
						 printf("\n");
						 }*/
						
						color rgb = hsvToRGB(hue, saturation, value);
						
						Vector3D initDisp = Vector3DSubtract(node->origin, lightPos);
						
						for(int i = 0; i < tex.height; i++){
							for(int j = 0; j < tex.width; j++){
								int texIndex = i*tex.width + j;
								float cov = 0.0f;
								{
									float empty = coverage[texIndex]/14.0f;
									float texData2[9] = {
										j==0||i==0?empty:coverage[texIndex-tex.width-1]/14.0f, i==0?empty:coverage[texIndex-tex.width]/7.0f, i==0||j==tex.width-1?empty:coverage[texIndex-tex.width+1]/14.0f,
										j==0?empty:coverage[texIndex-1]/7.0f, coverage[texIndex]/7.0f, j==tex.width-1?empty:coverage[texIndex+1]/7.0f,
										j==0||i==tex.height-1?empty:coverage[texIndex+tex.width-1]/14.0f, i==tex.height-1?empty:coverage[texIndex+tex.width]/7.0f, j==tex.width-1||i==tex.height-1?empty:coverage[texIndex+tex.width+1]/14.0f
									};
									for(int i = 0; i < 9; i++){
										cov += texData2[i];
									}
								}
								Vector3D pos = Vector3DAdd(initDisp, Vector3DAdd(Vector3DMultiply(dy, i-tex.height+1), Vector3DMultiply(dx, j)));
								//float dist = Vector3DMagnitude(pos);
								float dist = Vector3DDot(pos, node->normal);
								
								float dot = Vector3DDot(Vector3DNormalize(pos), Vector3DNormalize(node->normal));
								float falloff = 1 - 1/(radius*25.6f)*dist;
								
								//if(falloff > 2.0f){
								//	falloff = 2.0f;
								//}
								if(falloff < 0.0f){
									falloff = 0.0f;
								}
								//float oneOver2 = dot*radius;
								
								color newColor;
								color oldColor = texDat[texIndex];
								
								float scaling = cov*dot*falloff;
								
								newColor.r = scaling*rgb.r;
								newColor.g = scaling*rgb.g;
								newColor.b = scaling*rgb.b;
								newColor.a = 0xFF;
								
								texDat[texIndex] = ColorAdd(newColor, oldColor);
							}
						}
					}
					/*#if USE_32_Bit
					glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex.width, tex.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texDat);
					#else
					glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex.width, tex.height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, texDat);
					#endif*/
					
                   tex.textureData = [NSData dataWithBytesNoCopy:texDat length:tex.width * tex.height * sizeof(color)];
					free(coverage);
					//free(texDat);
				}
			}else{
				//GLubyte texDat = 0x00;
				//glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &texDat);
				
				void *data = calloc(tex.width * tex.height, sizeof(color));
				//((Byte *)data)[1] = 0xFF;
				tex.textureData = [NSData dataWithBytesNoCopy:data
													   length:tex.width * tex.height * sizeof(color)];
			}
		}else{
			/*glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			GLubyte texDat = 0xFF/2;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &texDat);*/
			
			color *data = calloc(tex.width * tex.height, sizeof(color));
			for(int i = 0;i < tex.width * tex.height;i++) {
				data[i].r = 0xFF/2;
				data[i].g = 0xFF/2;            
				data[i].b = 0xFF/2;
				data[i].a = 0xFF;
			}
			tex.textureData = [NSData dataWithBytesNoCopy:data
												   length:tex.width * tex.height * sizeof(color)];
		}
	}
	return [tex autorelease];
}

+ (id)textureWithBrightness:(Byte)bright{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		tex.width = 1;
		tex.height = 1;
		GLuint glTex;
		glGenTextures(1, &glTex);
		tex.glTex = glTex;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &bright);
	}
	return [tex autorelease];
}

- (void)bind:(int)index{
	glActiveTexture(GL_TEXTURE0+index);
	glBindTexture(GL_TEXTURE_2D, self.glTex);
}

- (void)dealloc{
	if(glTex_){
		glDeleteTextures(1, &glTex_);
		glTex_ = 0;
	}
	[textureData_ release];
	textureData_ = nil;
	[super dealloc];
}

@end
