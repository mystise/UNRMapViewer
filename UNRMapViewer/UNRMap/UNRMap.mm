//
//  UNRMap.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMap.h"

#import "UNRFile.h"
#import "UNRTexture.h"
#import "UNRNode.h"
#import "UNRCubeCamera.h"
#import "UNRProperty.h"
#import "Utilities.h"
#import "Matrix.h"
#import "GLCamera.h"

using Matrix::Matrix3D;
using Vector::Vector2D;

@interface UNRMap()
@property(nonatomic, assign) FPSCamera *cam;
@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_, lightMaps = lightMaps_, cubeMap = cubeMap_;

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
		
		self.cam = new FPSCamera;
		self.cam->setUp(Vector3D(0.0f, 0.0f, 1.0f));
		self.cam->lookTo(Vector3D(0.0f, 1.0f, 0.0f));
		
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
				self.cubeMap.camPos->x = [manager loadFloat];
				self.cubeMap.camPos->y = [manager loadFloat];
				self.cubeMap.camPos->z = [manager loadFloat];
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
	Matrix3D modelView;
	Matrix3D projection;
	
	projection.perspective(75.0f, 1.7f, 10000.0f, aspect);
	
	modelView = self.cam->glData();
	modelView.uniformScale(0.1f);
	modelView.scale(-1.0f, 1.0f, 1.0f);
	
	modelView = projection * modelView;
	
	//glStencilFunc(GL_ALWAYS, 0, UINT_MAX);
	[self.rootNode drawWithMatrix:modelView cubeMap:0 cameraPos:(vec3){self.cam->getPos().x, self.cam->getPos().y, self.cam->getPos().z}];
}

- (void)drawCubeMap:(float)dt{
	[self.cubeMap updateWithTimestep:dt];
	[self.cubeMap drawWithRootNode:self.rootNode];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray *touches2 = [touches allObjects];
	for(UITouch *touch in touches2){
		Vector2D newPoint = [touch locationInView:nil];
		Vector2D origPoint = [touch previousLocationInView:nil];
		Vector2D disp = newPoint - origPoint;
		if(newPoint.y < 512){
			self.cam->rotate(disp.x/10.0f, -disp.y/10.0f);
		}else{
			self.cam->moveRel(Vector3D(disp.y/10.0f, 0.0f, disp.x/10.0f));
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)setCam:(FPSCamera *)cam{
	if(cam_ != NULL){
		delete cam_;
	}
	cam_ = cam;
}

- (void)dealloc{
	if(cam_ != NULL){
		delete cam_;
		cam_ = NULL;
	}
	[lightMaps_ release];
	lightMaps_ = nil;
	[rootNode_ release];
	rootNode_ = nil;
	[super dealloc];
}

@end
