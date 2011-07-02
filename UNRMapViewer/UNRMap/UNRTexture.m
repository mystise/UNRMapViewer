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

@implementation UNRTexture

@synthesize width = width_, height = height_, glTex = glTex_;

+ (id)textureWithObject:(UNRExport *)obj{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		NSArray *palette = nil;
		int format = 0;
		BOOL masked = NO;
		BOOL transparent = NO;
		for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
			DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
			if([[prop.name.string lowercaseString] isEqualToString:@"format"]){
				format = [manager loadByte];
			}else if([[prop.name.string lowercaseString] isEqualToString:@"palette"]){
				UNRExport *obj = (UNRExport *)prop.object;
				palette = [obj.objectData valueForKey:@"palette"];
			}else if([[prop.name.string lowercaseString] isEqualToString:@"bmasked"]){
				masked = prop.special;
			}else if([[prop.name.string lowercaseString] isEqualToString:@"btransparent"]){
				transparent = prop.special;
			}
			[manager release];
		}
		
		GLuint glTex = 0;
		glGenTextures(1, &glTex);
		tex.glTex = glTex;
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, tex.glTex);
		
		tex.width = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"width"] intValue];
		tex.height = [[[[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:0] valueForKey:@"height"] intValue];
		for(int i = 0; i < [[obj.objectData valueForKey:@"mipMapCount"] intValue]; i++){
			NSMutableDictionary *texLevel = [[obj.objectData valueForKey:@"mipMapLevels"] objectAtIndex:i];
			DataManager *manager = [[DataManager alloc] initWithFileData:[texLevel valueForKey:@"mipMap"]];
			
			int levelWidth = [[texLevel valueForKey:@"width"] intValue];
			int levelHeight = [[texLevel valueForKey:@"height"] intValue];
			
			color *glTexData = calloc(levelWidth*levelHeight, sizeof(color));
			//stored width first
			
			if(format == 0){ //paletted
				for(int i = 0; i < levelHeight; i++){
					for(int j = 0; j < levelWidth; j++){
						Byte index = [manager loadByte];
						NSNumber *colorR = [[palette objectAtIndex:index] valueForKey:@"red"];
						NSNumber *colorG = [[palette objectAtIndex:index] valueForKey:@"green"];
						NSNumber *colorB = [[palette objectAtIndex:index] valueForKey:@"blue"];
						NSNumber *colorA = [[palette objectAtIndex:index] valueForKey:@"alpha"];
						if(index == 0 && masked == YES){
							colorA = [NSNumber numberWithUnsignedChar:0x00];
						}
						if(!transparent){
							colorA = [NSNumber numberWithUnsignedChar:0xFF];
						}
						glTexData[i*levelWidth + j] = (color){[colorR unsignedCharValue], [colorG unsignedCharValue], [colorB unsignedCharValue], [colorA unsignedCharValue]};
					}
				}
			}else{
				NSLog(@"Un-paletted textures are currently unsupported: %@\n", obj.name.string);
			}
			[manager release];
			
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			
			glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA, levelWidth, levelHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, glTexData);
			
			free(glTexData);
		}
		obj.objectData = nil;
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

color hsvToRGB(Byte inH, Byte inS, Byte inV) {
	color col = {0};
	float f, p, q, t;
	float h, s, v;
	float r = 0.0f, g = 0.0f, b = 0.0f;
	int i;
	if(inS == 0xFF){
		col.r = inV;
		col.g = inV;
		col.b = inV;
		col.a = 0xFF;
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
		col.r = r*0xFF;
		col.g = g*0xFF;
		col.b = b*0xFF;
		col.a = 0xFF;
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

+ (id)textureWithLightMap:(NSMutableDictionary *)lightMap data:(NSMutableData *)data lights:(NSMutableArray *)lights node:(UNRNode *)node{
	UNRTexture *tex = [[self alloc] init];
	if(tex){
		tex.width = [[lightMap valueForKey:@"uClamp"] unsignedIntValue]; //width and height are not necessarily powers of two
		tex.height = [[lightMap valueForKey:@"vClamp"] unsignedIntValue];
		int dataOffset = [[lightMap valueForKey:@"dataOffset"] unsignedIntValue];
		
		NSMutableArray *mapLights = [NSMutableArray array];
		
		GLuint texture;
		glGenTextures(1, &texture);
		tex.glTex = texture;
		glBindTexture(GL_TEXTURE_2D, tex.glTex);
		
		glPixelStorei(GL_PACK_ALIGNMENT, 1);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		if((node.surfFlags & PF_Unlit) != PF_Unlit){
			int iLightActors = [[lightMap valueForKey:@"iLightActors"] intValue];
			if(iLightActors != -1){
				id light = [lights objectAtIndex:iLightActors];
				for(int i = 1; ![light isKindOfClass:[NSNull class]] && i+iLightActors < [lights count]; i++){
					if([mapLights count] > 0){
						if([light isEqual:[mapLights lastObject]]){
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
					Byte *rawDat;
					NSData *subDat = [data subdataWithRange:NSMakeRange(dataOffset, bytesToLoad)];
					rawDat = (Byte *)[subDat bytes];
					color *texDat = calloc(tex.width*tex.height, sizeof(color));
					for(int y = 0; y < lightCount; y++){
						//load the light data
						Byte hue = 0, saturation = 255, value = 64, radius = 64;
						NSMutableArray *currentLight = [[[mapLights objectAtIndex:y] objectData] valueForKey:@"props"];
						for(UNRProperty *prop in currentLight){
							DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
							if([prop.name.string isEqualToString:@"LightBrightness"]){
								value = [manager loadByte];
							}else if([prop.name.string isEqualToString:@"LightSaturation"]){
								saturation = [manager loadByte];
							}else if([prop.name.string isEqualToString:@"LightHue"]){
								hue = [manager loadByte];
							}else if([prop.name.string isEqualToString:@"LightEffect"]){
								printf("\t");
								printLightType([manager loadByte]);
								printf("\n");
							}else if([prop.name.string isEqualToString:@"LightRadius"]){
								radius = [manager loadByte];
							}
							[manager release];
						}
						color rgb = hsvToRGB(hue, saturation, value);
						
						for(int i = 0; i < tex.height; i++){
							for(int j = 0; j < tex.width; j+=8){
								for(int x = 0; x < 8 && x+j < tex.width; x++){
									int texIndex = i*tex.width + j+x;
									int rawIndex = i*nextWidth/8 + j/8 + y*texSize;
									float newDat = ((rawDat[rawIndex]>>x)&0x01);
									
									//if(newDat == 0.0f){
									//	newDat = 0.5f;
									//}
									
									color newColor = texDat[texIndex];
									newColor.r += newDat*rgb.r;
									newColor.g += newDat*rgb.g;
									newColor.b += newDat*rgb.b;
									newColor.a = 0xFF;
									/*if(newColor.r == 0x00){
									 newColor.r -= value/2;
									 newColor.g -= value/2;
									 newColor.b -= value/2;
									 or
									 newColor.r /= 2;
									 newColor.g /= 2;
									 newColor.b /= 2;
									 }*/
									
									texDat[texIndex] = newColor;
								}
							}
						}
					}
					
//					printf("Lightmap: w:%i h:%i lc:%i\n\t", tex.width, tex.height, lightCount);
//					printf("texData:\n\t");
//					for(int i = tex.height-1; i >= 0; i--){
//						for(int j = 0; j < tex.width; j++){
//							printf(" %2x", texDat[i*tex.width+j].r);
//						}
//						printf("\n\t");
//					}
//					
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
					glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
					
					glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex.width, tex.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, texDat);
				}else{
					GLubyte texDat = 0xFF/2;
					glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &texDat);
					printf("\tfailed!!! not enough data!\n");
				}
			}else{
				GLubyte texDat = 0x00;
				glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &texDat);
			}
		}else{
			GLubyte texDat = 0xFF;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 1, 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, &texDat);
		}
		
		glPixelStorei(GL_PACK_ALIGNMENT, 4);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
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
	[super dealloc];
}

@end
