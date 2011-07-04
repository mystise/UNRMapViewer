//
//  UNRMap.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMap.h"

#import "UNRFile.h"
#import "UNRProperty.h"

#import "UNRTexture.h"
#import "UNRNode.h"
#import "UNRCubeCamera.h"

#import "UNRCamera.h"
#import "Matrix3D.h"
#import "Vector3D.h"

@interface UNRMap()

@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_, lightMaps = lightMaps_, cubeMap = cubeMap_;
@synthesize stickPos = stickPos_, stickPrevPos = stickPrevPos_, lookPos = lookPos_, lookPrevPos = lookPrevPos_, zones = zones_, actors = actors_;

- (id)initWithLevel:(NSMutableDictionary *)level andFile:(UNRFile *)file label:(UILabel *)label progress:(UIProgressView *)progress{
	self = [super init];
	if(self != nil){
		dispatch_queue_t mainThread = dispatch_get_main_queue();
		NSMutableDictionary *model = [[level valueForKey:@"bspModel"] objectData];
		
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		self.lightMaps = [NSMutableDictionary dictionary];
		self.zones = [NSMutableDictionary dictionary];
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Loading nodes...";
			progress.progress = 0.5f;
		});
		NSMutableDictionary *attrib = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [[model valueForKey:@"vectors"] valueForKey:@"vector"], @"vectors",
									   [[model valueForKey:@"points"] valueForKey:@"point"], @"points",
									   [model valueForKey:@"verts"], @"verts",
									   [[model valueForKey:@"lights"] valueForKey:@"light"], @"lights",
									   self, @"map",
									   [NSNumber numberWithInt:0], @"iNode",
									   nil];
		UNRNode *node = [[UNRNode alloc] initWithModel:model attributes:attrib];//nodeNumber:0 file:file map:self
		self.rootNode = node;
		[node release];
		
		UNRCubeCamera *cam = [[UNRCubeCamera alloc] init];
		self.cubeMap = cam;
		[cam release];
		
		self.cam = [[UNRCamera alloc] init];
		self.cam.up = Vector3DCreate(0.0f, 0.0f, 1.0f);
		self.cam.look = Vector3DCreate(0.0f, 1.0f, 0.0f);
		
		self.actors = [NSMutableDictionary dictionary];
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Loading actors...";
			progress.progress = 0.6f;
		});
		
		for(UNRExport *obj in [[level valueForKey:@"actors"] valueForKey:@"actor"]){
			if(![obj isKindOfClass:[NSNull class]]){
				NSString *className = obj.classObj.name.string;
				//ignore all types not relevant to us
				if(![className isEqualToString:@"Brush"] && ![className isEqualToString:@"Camera"] && ![className isEqualToString:@"PathNode"]){
					if([self.actors valueForKey:className] == nil){
						[self.actors setValue:[NSMutableArray array] forKey:className];
					}
					[obj loadPlugin:file];
					[[self.actors valueForKey:className] addObject:obj];
				}
			}
		}
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Initializing skybox...";
			progress.progress = 0.7f;
		});
		NSMutableArray *skyBox = nil;
		NSMutableDictionary *skyBoxes = [NSMutableDictionary dictionary];
		//find the skyBoxInfo with highDetail set to 1
		for(UNRExport *obj in [self.actors valueForKey:@"SkyZoneInfo"]){
			for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
				if([prop.name.string isEqualToString:@"bHighDetail"]){
					if(prop.special == YES){
						[skyBoxes setValue:[obj.objectData valueForKey:@"props"] forKey:@"highDetail"];
					}
				}
			}
			if([skyBoxes valueForKey:@"highDetail"] == nil){
				[skyBoxes setValue:[obj.objectData valueForKey:@"props"] forKey:@"lowDetail"];
			}
		}
		
		if([skyBoxes valueForKey:@"highDetail"] != nil){
			skyBox = [skyBoxes valueForKey:@"highDetail"];
		}else{
			skyBox = [skyBoxes valueForKey:@"lowDetail"];
		}
		
		for(UNRProperty *prop in skyBox){
			DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
			if([prop.name.string isEqualToString:@"Location"]){
				Vector3D camPos;
				camPos.x = [manager loadFloat];
				camPos.y = [manager loadFloat];
				camPos.z = [manager loadFloat];
				//camPos = Vector3DMultiply(camPos, 0.1f);
				self.cubeMap.cam.pos = camPos;
				self.cubeMap.cam.up = Vector3DCreate(0.0f, 0.0f, 1.0f);
				self.cubeMap.cam.look = Vector3DCreate(0.0f, 1.0f, 0.0f);
				//self.cam.pos = camPos;
			}else if([prop.name.string isEqualToString:@"RotationRate"]){
				self.cubeMap.drX = [manager loadInt]*45/8192;
				self.cubeMap.drY = [manager loadInt]*45/8192;
				self.cubeMap.drZ = [manager loadInt]*45/8192;
			}
			[manager release];
		}
		
		for(UNRExport *obj in [self.actors valueForKey:@"PlayerStart"]){
			for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
				DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
				if([prop.name.string isEqualToString:@"Location"]){
					Vector3D camPos;
					camPos.x = [manager loadFloat];
					camPos.y = [manager loadFloat];
					camPos.z = [manager loadFloat];
					self.cam.pos = camPos;
				}else if([prop.name.string isEqualToString:@"Rotation"]){
					self.cam.rotX = [manager loadInt]*45/8192;
					self.cam.rotY = [manager loadInt]*45/8192;
					self.cam.rotZ = [manager loadInt]*45/8192;
				}else{
					
				}
				[manager release];
			}
		}
		
		//setup all inventory spots
	}
	return self;
}

- (void)draw:(float)aspect withTimestep:(float)dt{
	CGPoint disp = CGPointMake(self.stickPrevPos.x - self.stickPos.x, self.stickPrevPos.y - self.stickPos.y);
	[self.cam move:Vector3DCreate(disp.y*2.0f*dt, 0.0f, disp.x*2.0f*dt)];
	
	disp = CGPointMake(self.lookPrevPos.x - self.lookPos.x, self.lookPrevPos.y - self.lookPos.y);
	self.cam.rotX += disp.x/5.0f*dt;
	self.cam.rotY += -disp.y/5.0f*dt;
//	self.cam.rotX += self.cubeMap.drX * dt;
//	self.cam.rotY += self.cubeMap.drY * dt;
//	self.cam.rotZ += self.cubeMap.drZ * dt;
	
	Matrix3D modelView;
	Matrix3D projection;
	Matrix3DIdentity(projection);
	
	Matrix3DPerspective(projection, 90.0f, 17.0f, USHRT_MAX, aspect);
	
	[self.cam getGLData:modelView];
	//Matrix3DUniformScale(modelView, 0.1f);
	
	Matrix3D res;
	Matrix3DMultiply(projection, modelView, res);
	
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
	glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
	
	//glDepthMask(GL_FALSE);
	Vector3D camPos = self.cam.pos;
	//camPos = Vector3DMultiply(camPos, 0.1f);
	//glDisable(GL_DEPTH_TEST);
	[self.rootNode drawWithMatrix:res camPos:camPos];
	
	[self.cubeMap updateWithTimestep:dt];
	[self.cubeMap drawWithRootNode:self.rootNode camera:self.cam projMat:projection];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	for(UITouch *touch in [touches allObjects]){
		CGPoint point = [touch locationInView:nil];
		if(point.y < 512){
			self.lookPos = point;
			self.lookPrevPos = point;
		}else{
			self.stickPos = point;
			self.stickPrevPos = point;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	for(UITouch *touch in [touches allObjects]){
		CGPoint prevPos = [touch previousLocationInView:nil];
		CGPoint curPos = [touch locationInView:nil];
		if(prevPos.x == self.stickPrevPos.x && prevPos.y == self.stickPrevPos.y){
			self.stickPrevPos = curPos;
		}else if(prevPos.x == self.lookPrevPos.x && prevPos.y == self.lookPrevPos.y){
			self.lookPrevPos = curPos;
		}
		/*Vector2D newPoint = [touch locationInView:nil];
		 Vector2D origPoint = [touch previousLocationInView:nil];
		 Vector2D disp = newPoint - origPoint;
		 if(newPoint.y < 512){
		 self.cam->rotate(disp.x/10.0f, -disp.y/10.0f);
		 }else{
		 self.cam->moveRel(Vector3D(disp.y/10.0f, 0.0f, disp.x/10.0f));
		 }*/
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	for(UITouch *touch in [touches allObjects]){
		CGPoint newPos = [touch locationInView:nil];
		CGPoint prevPos = [touch previousLocationInView:nil];
		if((prevPos.x == self.stickPrevPos.x && prevPos.y == self.stickPrevPos.y) || (newPos.x == self.stickPrevPos.x && newPos.y == self.stickPrevPos.y)){
			self.stickPrevPos = CGPointMake(0.0f, 0.0f);
			self.stickPos = CGPointMake(0.0f, 0.0f);
		}else if((prevPos.x == self.lookPrevPos.x && prevPos.y == self.lookPrevPos.y) || (newPos.x == self.lookPrevPos.x && newPos.y == self.lookPrevPos.y)){
			self.lookPrevPos = CGPointMake(0.0f, 0.0f);
			self.lookPos = CGPointMake(0.0f, 0.0f);
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self touchesEnded:touches withEvent:event];
}

- (void)dealloc{
	[cam_ release];
	cam_ = nil;
	[lightMaps_ release];
	lightMaps_ = nil;
	[shaders_ release];
	shaders_ = nil;
	[textures_ release];
	textures_ = nil;
	[zones_ release];
	zones_ = nil;
	[actors_ release];
	actors_ = nil;
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
