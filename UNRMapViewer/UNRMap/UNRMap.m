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
#import "UNRFrustum.h"

@interface UNRMap()

@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_, lightMaps = lightMaps_, cubeMap = cubeMap_;
@synthesize stickPos = stickPos_, stickPrevPos = stickPrevPos_, lookPos = lookPos_, lookPrevPos = lookPrevPos_, zones = zones_, actors = actors_, classes = classes_;

- (id)initWithLevel:(NSMutableDictionary *)level andFile:(UNRFile *)file label:(UILabel *)label progress:(UIProgressView *)progress{
	self = [super init];
	if(self != nil){
		dispatch_queue_t mainThread = dispatch_get_main_queue();
		NSMutableDictionary *model = [[level valueForKey:@"bspModel"] objectData];
		
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		self.lightMaps = [NSMutableDictionary dictionary];
		self.zones = [NSMutableDictionary dictionary];
		self.actors = [NSMutableDictionary dictionary];
		self.classes = [NSMutableDictionary dictionary];
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Loading actors...";
			progress.progress = 0.6f;
		});
		
		for(UNRExport *obj in [[level valueForKey:@"actors"] valueForKey:@"actor"]){
			if(![obj isKindOfClass:[NSNull class]]){
				NSString *className = obj.classObj.name.string;
				//ignore all types not relevant to us
				if(![className isEqualToString:@"Brush"] &&
				   ![className isEqualToString:@"Camera"] &&
				   ![className isEqualToString:@"PathNode"] &&
				   ![className isEqualToString:@"Trigger"] &&
				   ![className isEqualToString:@"Ambushpoint"] &&
				   ![className isEqualToString:@"translocdest"] &&
				   ![className isEqualToString:@"LiftExit"] &&
				   ![className isEqualToString:@"DefensePoint"] &&
				   ![className isEqualToString:@"SpecialEvent"] &&
				   ![className isEqualToString:@"teamtrigger"] &&
				   ![className isEqualToString:@"DistanceViewTrigger"] &&
				   ![className isEqualToString:@"BlockAll"] &&
				   ![className isEqualToString:@"InterpolationPoint"] &&
				   ![className isEqualToString:@"LiftCenter"] &&
				   ![className isEqualToString:@"JumpExit"] &&
				   ![className isEqualToString:@"JumpCenter"]){
					if([self.actors valueForKey:className] == nil){
						[self.actors setValue:[NSMutableArray array] forKey:className];
					}
					obj.data = nil;
					[[self.actors valueForKey:className] addObject:[obj.objectData valueForKey:@"props"]];
					
					if([self.classes valueForKey:className] == nil){
						UNRExport *defaultProps = (UNRExport *)obj.classObj;
						if([defaultProps isKindOfClass:[UNRImport class]]){
							UNRImport *imp = (UNRImport *)defaultProps;
							defaultProps = imp.obj;
						}
						NSMutableDictionary *classProps = [defaultProps.objectData valueForKey:@"props"];
						
						[self.classes setValue:classProps forKey:className];
					}
				}
			}
		}
		
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
		UNRNode *node = UNRNodeCreate(model, attrib);
		self.rootNode = node;
		
		UNRCubeCamera *cubeCam = [[UNRCubeCamera alloc] init];
		self.cubeMap = cubeCam;
		self.cubeMap.cam.up = Vector3DCreate(0.0f, 0.0f, 1.0f);
		self.cubeMap.cam.look = Vector3DCreate(0.0f, 1.0f, 0.0f);
		[cubeCam release];
		
		UNRCamera *cam = [[UNRCamera alloc] init];
		self.cam = cam;
		[cam release];
		self.cam.up = Vector3DCreate(0.0f, 0.0f, 1.0f);
		self.cam.look = Vector3DCreate(0.0f, 1.0f, 0.0f);
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Initializing skybox...";
			progress.progress = 0.7f;
		});
		NSMutableDictionary *skyBox = nil;
		for(NSMutableDictionary *obj in [self.actors valueForKey:@"SkyZoneInfo"]){
			UNRProperty *prop = [obj valueForKey:@"bHighDetail"];
			if(prop.special == YES){
				skyBox = obj;
			}else if(skyBox == nil){
				skyBox = obj;
			}
		}
		
		{
			UNRProperty *location = [skyBox valueForKey:@"Location"];
			Vector3D camPos;
			camPos.x = [location.manager loadFloat];
			camPos.y = [location.manager loadFloat];
			camPos.z = [location.manager loadFloat];
			self.cubeMap.cam.pos = camPos;
			
			UNRProperty *rotRate = [skyBox valueForKey:@"RotationRate"];
			self.cubeMap.drX = [rotRate.manager loadInt]*45/8192;
			self.cubeMap.drY = [rotRate.manager loadInt]*45/8192;
			self.cubeMap.drZ = [rotRate.manager loadInt]*45/8192;
		}
		
		NSMutableDictionary *obj = [[self.actors valueForKey:@"PlayerStart"] objectAtIndex:0];
		{
			UNRProperty *location = [obj valueForKey:@"Location"];
			Vector3D camPos;
			camPos.x = [location.manager loadFloat];
			camPos.y = [location.manager loadFloat];
			camPos.z = [location.manager loadFloat];
			self.cam.pos = camPos;
			
			UNRProperty *rotation = [obj valueForKey:@"Rotation"];
			self.cam.rotX = [rotation.manager loadInt]*45/8192;
			self.cam.rotY = [rotation.manager loadInt]*45/8192;
			self.cam.rotZ = [rotation.manager loadInt]*45/8192;
		}
		
		for(NSMutableDictionary *obj in [self.actors valueForKey:@"InventorySpot"]){
			printf("Inventory!\n");
			UNRExport *markedItem = [obj valueForKey:@"markedItem"];
			if([markedItem isKindOfClass:[UNRImport class]]){
				UNRImport *item = (UNRImport *)markedItem;
				markedItem = item.obj;
			}
			//what I want is markedItem.class.defaultProperties.mesh and then load that into memory, and release all the rest.
		}
		//setup all inventory spots
	}
	return self;
}

- (void)draw:(float)aspect withTimestep:(float)dt{
	CGPoint disp = CGPointMake(self.stickPrevPos.x - self.stickPos.x, self.stickPrevPos.y - self.stickPos.y);
	[self.cam move:Vector3DCreate(disp.y*3.0f*dt, 0.0f, disp.x*3.0f*dt)];
	
	disp = CGPointMake(self.lookPrevPos.x - self.lookPos.x, self.lookPrevPos.y - self.lookPos.y);
	self.cam.rotX += disp.x/3.0f*dt;
	self.cam.rotY += -disp.y/3.0f*dt;
	
	Matrix3D modelView;
	Matrix3D projection;
	Matrix3DIdentity(projection);
	
	Matrix3DPerspective(projection, 90.0f, 17.0f, USHRT_MAX, aspect);
	
	[self.cam getGLData:modelView];
	
	Matrix3D res;
	Matrix3DMultiply(projection, modelView, res);
	
	UNRFrustum frustum;
	UNRFrustumCreate(frustum, res);
	
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
	glStencilOp(GL_KEEP, GL_KEEP, GL_ZERO);
	
	Vector3D camPos = self.cam.pos;
	glDepthRangef(0.5f, 1.0f);
	glDepthMask(GL_TRUE);
	UNRNodeDraw(self.rootNode, res, frustum, camPos, NO, NO);
	//[self.rootNode drawWithMatrix:res frustum:frustum camPos:camPos nonSolid:NO];
	
	glDepthRangef(0.0f, 0.5f);
	[self.cubeMap updateWithTimestep:dt];
	[self.cubeMap drawWithRootNode:self.rootNode camera:self.cam projMat:projection];
	
	//glDepthRangef(0.5f, 1.0f);
	//[self.rootNode drawWithMatrix:res frustum:frustum camPos:camPos nonSolid:YES];
	//UNRNodeDraw(self.rootNode, res, frustum, camPos, YES, NO);
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
	[classes_ release];
	classes_ = nil;
	if(rootNode_){
		UNRNodeDelete(rootNode_);
		rootNode_ = nil;
	}
	//[rootNode_ release];
	//rootNode_ = nil;
	[super dealloc];
}

@end
