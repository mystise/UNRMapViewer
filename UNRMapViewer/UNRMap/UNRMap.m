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

//#import "Utilities.h"
#import "UNRCamera.h"
#import "Matrix3D.h"
#import "Vector3D.h"

//#import "Matrix.h"
//#import "GLCamera.h"

//using Matrix::Matrix3D;
//using Vector::Vector2D;

@interface UNRMap()

@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_, lightMaps = lightMaps_, cubeMap = cubeMap_;
@synthesize stickPos = stickPos_, stickPrevPos = stickPrevPos_, lookPos = lookPos_, lookPrevPos = lookPrevPos_;

- (id)initWithModel:(NSMutableDictionary *)model andFile:(UNRFile *)file{
	self = [super init];
	if(self != nil){
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		self.lightMaps = [NSMutableDictionary dictionary];
		UNRNode *node = [[UNRNode alloc] initWithModel:model nodeNumber:0 file:file map:self];
		self.rootNode = node;
		[node release];
		
		UNRCubeCamera *cam = [[UNRCubeCamera alloc] init];
		self.cubeMap = cam;
		[cam release];
		
		self.cam = [[UNRCamera alloc] init];
		self.cam.up = Vector3DCreate(0.0f, 0.0f, 1.0f);
		self.cam.look = Vector3DCreate(0.0f, 1.0f, 0.0f);
		//self.cam->setUp(Vector3D(0.0f, 0.0f, 1.0f));
		//self.cam->lookTo(Vector3D(0.0f, 1.0f, 0.0f));
		
		NSMutableArray *skyBox = nil;
		//find the skyBoxInfo with highDetail set to 1
		for(UNRExport *obj in file.objects){
			if([obj.classObj.name.string isEqualToString:@"SkyZoneInfo"]){
				[obj loadPlugin:file];
				for(UNRProperty *prop in [obj.objectData valueForKey:@"props"]){
					if([prop.name.string isEqualToString:@"bHighDetail"]){
						if(prop.special == YES){
							skyBox = [obj.objectData valueForKey:@"props"];
							break;
						}
					}
				}
			}
		}
		
		for(UNRProperty *prop in skyBox){
			DataManager *manager = [[DataManager alloc] initWithFileData:prop.data];
			if([prop.name.string isEqualToString:@"Location"]){
				Vector3D camPos;
				camPos.x = [manager loadFloat];
				camPos.y = [manager loadFloat];
				camPos.z = [manager	loadFloat];
				self.cubeMap.camPos = camPos;
//				self.cubeMap.camPos.x = [manager loadFloat];
//				self.cubeMap.camPos.y = [manager loadFloat];
//				self.cubeMap.camPos.z = [manager loadFloat];
			}else if([prop.name.string isEqualToString:@"RotationRate"]){
				self.cubeMap.drX = [manager loadInt]/(float)0xFFFF;
				self.cubeMap.drY = [manager loadInt]/(float)0xFFFF;
				self.cubeMap.drZ = [manager loadInt]/(float)0xFFFF;
			}else if([prop.name.string isEqualToString:@"Region"]){
				//possibly do something with region
			}
			[manager release];
		}
	}
	return self;
}

- (void)draw:(float)aspect withTimestep:(float)dt{
	CGPoint disp = CGPointMake(self.stickPrevPos.x - self.stickPos.x, self.stickPrevPos.y - self.stickPos.y);
	//Vector2D disp =  Vector2D(self.stickPrevPos) - Vector2D(self.stickPos);
	[self.cam move:Vector3DCreate(disp.y/10.0f*dt, 0.0f, disp.x/10.0f*dt)];
	//[self.cam moveRelativeX:disp.y/10.0f*dt Y:0.0f Z:disp.x/10.0f*dt];
	
	//disp = Vector2D(self.lookPrevPos) - Vector2D(self.lookPos);
	disp = CGPointMake(self.lookPrevPos.x - self.lookPos.x, self.lookPrevPos.y - self.lookPos.y);
	self.cam.rotX += disp.x/5.0f*dt;
	self.cam.rotY += -disp.y/5.0f*dt;
	//[self.cam rotateX:disp.x/5.0f*dt Y:-disp.y/5.0f*dt];
	
	Matrix3D modelView;
	Matrix3D projection;
	Matrix3DIdentity(projection);
	
	Matrix3DPerspective(projection, 90.0f, 1.7f, USHRT_MAX/10.0f, aspect);
	
	[self.cam getGLData:modelView];
	Matrix3DUniformScale(modelView, 0.1f);
	Matrix3DScale(modelView, -1.0f, 1.0f, 1.0f);
	
	Matrix3D res;
	Matrix3DMultiply(projection, modelView, res);
	
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	[self.rootNode drawWithMatrix:res cameraPos:self.cam.pos];
	
	[self drawCubeMap:dt];
}

- (void)drawCubeMap:(float)dt{
	[self.cubeMap updateWithTimestep:dt];
	[self.cubeMap drawWithRootNode:self.rootNode camera:self.cam];
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
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
