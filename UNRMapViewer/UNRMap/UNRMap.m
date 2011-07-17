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
#import "UNRCubeCamera.h"

#import "UNRCamera.h"
#import "UNRFrustum.h"
#import "UNRTextureMap.h"

CFStringRef NodeDescription(const void *value) {
  return (CFStringRef)@"node";
}

@interface UNRMap()

@end

@implementation UNRMap

@synthesize rootNode = rootNode_, textures = textures_, shaders = shaders_, cam = cam_, lightMaps = lightMaps_, cubeMap = cubeMap_;
@synthesize stickPos = stickPos_, stickPrevPos = stickPrevPos_, lookPos = lookPos_, lookPrevPos = lookPrevPos_, actors = actors_, classes = classes_;
@synthesize meshes = meshes_, meshCount = meshCount_, meshMats = meshMats_, meshMatCount = meshMatCount_;
@synthesize lightMapTexMap = lightMapTexMap_;

- (id)initWithLevel:(NSMutableDictionary *)level andFile:(UNRFile *)file label:(UILabel *)label progress:(UIProgressView *)progress{
	self = [super init];
	if(self != nil){
		dispatch_queue_t mainThread = dispatch_get_main_queue();
		NSMutableDictionary *model = [[level valueForKey:@"bspModel"] objectData];
		
		self.textures = [NSMutableDictionary dictionary];
		self.shaders = [NSMutableDictionary dictionary];
		self.lightMaps = [NSMutableDictionary dictionary];
		self.actors = [NSMutableDictionary dictionary];
		self.classes = [NSMutableDictionary dictionary];
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Loading actors...";
			progress.progress = 0.6f;
		});
		
		NSMutableDictionary *flagProps = nil;
		
		for(UNRExport *obj in [[level valueForKey:@"actors"] valueForKey:@"actor"]){
			if(![obj isKindOfClass:[NSNull class]]){
				NSString *className = obj.classObj.name.string;
				//ignore all types not relevant to us
				if(![className isEqualToString:@"Brush"] &&
				   ![className isEqualToString:@"Camera"] &&
				   ![className isEqualToString:@"PathNode"] &&
				   ![className isEqualToString:@"Trigger"] &&
				   ![className isEqualToString:@"Ambushpoint"] &&
				   ![className isEqualToString:@"TranslocDest"] &&
				   ![className isEqualToString:@"LiftExit"] &&
				   ![className isEqualToString:@"DefensePoint"] &&
				   ![className isEqualToString:@"SpecialEvent"] &&
				   ![className isEqualToString:@"teamtrigger"] &&
				   ![className isEqualToString:@"DistanceViewTrigger"] &&
				   ![className isEqualToString:@"BlockAll"] &&
				   ![className isEqualToString:@"InterpolationPoint"] &&
				   ![className isEqualToString:@"LiftCenter"] &&
				   ![className isEqualToString:@"JumpExit"] &&
				   ![className isEqualToString:@"JumpCenter"] &&
				   ![className isEqualToString:@"botbait"] &&
				   ![className isEqualToString:@"AmbientSound"]){
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
				if([className isEqualToString:@"FlagBase"] && flagProps == nil){
					printf("Found!!\n");
					UNRImport *flagObj = (UNRImport *)obj.classObj;
					
					flagProps = [flagObj.obj.objectData valueForKey:@"props"];
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
      
      // setup the datastructure to hold the nodes that are usign the same texture
      NSMutableDictionary *nodes = [NSMutableDictionary dictionaryWithCapacity:[[self textures] count]];
      for(NSString *textureName in [self textures]) {
        CFArrayCallBacks callbacks = {0, NULL, NULL, NodeDescription, NULL};
        CFMutableArrayRef array = CFArrayCreateMutable(NULL, 0, &callbacks);
        [nodes setValue:(id)array forKey:textureName];
      }
      
      UNRNodeGroupNodesOnTextureName(self.rootNode, nodes);
      NSMutableDictionary *flattendVertexData = [NSMutableDictionary dictionaryWithCapacity:[[self textures] count]];
      for(NSString *textureName in nodes) {
        CFArrayCallBacks vertexDataCallbacks = {0, VertexDataRetainCallBack, VertexDataReleaseCallBack, VertexDataCopyDescriptionCallBack, NULL};
        CFMutableArrayRef vertexDataArray = CFArrayCreateMutable(NULL, 0, &vertexDataCallbacks);
        CFArrayRef unrNodeArray = (CFArrayRef)[nodes objectForKey:textureName];
        for(int i = 0;i < CFArrayGetCount(unrNodeArray);i++) {
          UNRNode *unrNode = (UNRNode*)CFArrayGetValueAtIndex(unrNodeArray, i);
          if(NULL == unrNode->vertexData) {
            break;
          }
          int start = CFArrayGetCount(vertexDataArray);
          for(int j = 0;j < unrNode->vertCount;j++) {
            CFArrayInsertValueAtIndex(vertexDataArray, start + j, (const void *)(&(unrNode->vertexData[j])));
          }
        }
        if(0 < CFArrayGetCount(vertexDataArray)) {
          [flattendVertexData setObject:(id)vertexDataArray forKey:textureName];
          CFRelease(vertexDataArray);
        } else {
          CFRelease(vertexDataArray);
        }
      }
      
      UNRTextureMap *map = [[UNRTextureMap alloc] initWithSize:CGSizeMake(1024, 1024)];
      [map addTexturesFromNode:self.rootNode];
      [map uploadToGPU];
      self.lightMapTexMap = map;
      [map release];
      
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
		
		{
			NSMutableDictionary *obj = [[self.actors valueForKey:@"PlayerStart"] objectAtIndex:0];
			
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
		
		dispatch_async(mainThread, ^(void){
			label.text = @"Loading meshes...";
			progress.progress = 0.8f;
		});
		NSMutableArray *array = [self.actors valueForKey:@"InventorySpot"];
		NSMutableDictionary *obj = [array objectAtIndex:0];
		int index = 1;
		while(obj != nil){
			if(index < [array count]){
				obj = [array objectAtIndex:index];//NSMutableDictionary *obj in [self.actors valueForKey:@"InventorySpot"];
				index++;
			}else{
				obj = nil;
				break;
			}
			NSMutableDictionary *markedItem = [[[[obj valueForKey:@"markedItem"] object] objectData] valueForKey:@"props"];
			UNRExport *classObj = (UNRExport *)[[[obj valueForKey:@"markedItem"] object] classObj];
			if([classObj isKindOfClass:[UNRImport class]]){
				UNRImport *item = (UNRImport *)classObj;
				classObj = item.obj;
			}
			NSMutableDictionary *props = [classObj.objectData valueForKey:@"props"];
			
			UNRExport *meshObj = [[props valueForKey:@"Mesh"] object];
			NSMutableDictionary *mesh = [meshObj objectData];
			int nameRef = meshObj.nameRef;
			
			int index = -1;
			for(int i = 0; i < self.meshCount; i++){
				if(self.meshes[i]->nameIndex == nameRef){
					index = i;
					break;
				}
			}
			
			if(index == -1){
				self.meshCount++;
				self.meshes = realloc(self.meshes, self.meshCount*sizeof(UNRMesh *));
				
				self.meshes[self.meshCount-1] = UNRMeshCreate(mesh, nameRef, 0);
				index = self.meshCount-1;
			}
			
			self.meshMatCount++;
			self.meshMats = realloc(self.meshMats, self.meshMatCount*sizeof(UNRMeshContainer));
			self.meshMats[self.meshMatCount-1].meshUsed = index;
			
			UNRProperty *locProp = [markedItem valueForKey:@"Location"];
			Vector3D position;
			position.x = [locProp.manager loadFloat];
			position.y = [locProp.manager loadFloat];
			position.z = [locProp.manager loadFloat];
			
			UNRProperty *rotProp = [markedItem valueForKey:@"Rotation"];
			Vector3D rotation;
			rotation.x = [rotProp.manager loadInt]*45/8192;
			rotation.y = [rotProp.manager loadInt]*45/8192;
			rotation.z = [rotProp.manager loadInt]*45/8192;
			
			Matrix3D mat;
			Matrix3DIdentity(mat);
			
			Matrix3DTranslate(mat, position.x, position.y, position.z);
			Matrix3DRotateX(mat, -self.meshes[index]->rotation.z-rotation.x);
			Matrix3DRotateY(mat, self.meshes[index]->rotation.y+rotation.z);
			Matrix3DRotateZ(mat, self.meshes[index]->rotation.x+rotation.y);
			Matrix3DScale(mat, self.meshes[index]->scale.x*10.0f, self.meshes[index]->scale.y*10.0f, self.meshes[index]->scale.z*5.0f);
			
			Matrix3DCopy(mat, self.meshMats[self.meshMatCount-1].matrix);
		}
		
		/*array = [self.actors valueForKey:@"FlagBase"];
		obj = [array objectAtIndex:0];
		index = 1;
		while(obj != nil){
			if(index < [array count]){
				obj = [array objectAtIndex:index];
				index++;
			}else{
				obj = nil;
				break;
			}
			NSMutableDictionary *markedItem = obj;
			
			UNRExport *meshObj = [[flagProps valueForKey:@"Mesh"] object];
			NSMutableDictionary *mesh = [meshObj objectData];
			int nameRef = meshObj.nameRef;
			
			int index = -1;
			for(int i = 0; i < self.meshCount; i++){
				if(self.meshes[i]->nameIndex == nameRef){
					index = i;
					break;
				}
			}
			
			if(index == -1){
				self.meshCount++;
				self.meshes = realloc(self.meshes, self.meshCount*sizeof(UNRMesh *));
				
				self.meshes[self.meshCount-1] = UNRMeshCreate(mesh, nameRef, 0);
				index = self.meshCount-1;
			}
			
			self.meshMatCount++;
			self.meshMats = realloc(self.meshMats, self.meshMatCount*sizeof(UNRMeshContainer));
			self.meshMats[self.meshMatCount-1].meshUsed = index;
			
			UNRProperty *locProp = [markedItem valueForKey:@"Location"];
			Vector3D position;
			position.x = [locProp.manager loadFloat];
			position.y = [locProp.manager loadFloat];
			position.z = [locProp.manager loadFloat];
			
			UNRProperty *rotProp = [markedItem valueForKey:@"Rotation"];
			Vector3D rotation;
			rotation.x = [rotProp.manager loadInt]*45/8192;
			rotation.y = [rotProp.manager loadInt]*45/8192;
			rotation.z = [rotProp.manager loadInt]*45/8192;
			
			Matrix3D mat;
			Matrix3DIdentity(mat);
			
			Matrix3DTranslate(mat, position.x, position.y, position.z);
			Matrix3DRotateX(mat, -self.meshes[index]->rotation.z-rotation.x);
			Matrix3DRotateY(mat, self.meshes[index]->rotation.y+rotation.z);
			Matrix3DRotateZ(mat, self.meshes[index]->rotation.x+rotation.y);
			Matrix3DScale(mat, self.meshes[index]->scale.x*10.0f, self.meshes[index]->scale.y*10.0f, self.meshes[index]->scale.z*5.0f);
			
			Matrix3DCopy(mat, self.meshMats[self.meshMatCount-1].matrix);
		}*/
		
		self.actors = nil;
		self.classes = nil;
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
	
	Vector3D camPos = self.cam.pos;
	glDepthRangef(0.5f, 1.0f);
	glStencilFunc(GL_ALWAYS, 1, UINT_MAX);
	glStencilOp(GL_KEEP, GL_KEEP, GL_ZERO);
	
	for(int i = 0; i < self.meshMatCount; i++){
		Matrix3D mat;
		Matrix3DMultiply(res, self.meshMats[i].matrix, mat);
		
		UNRMeshContainer *meshMats = self.meshMats;
		int meshIndex = meshMats[i].meshUsed;
		UNRMesh **meshes = self.meshes;
		UNRMesh *mesh = meshes[meshIndex];
		
		UNRMeshDraw(mesh, mat, frustum);
	}
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, self.lightMapTexMap.lightMapTexID);
	UNRNodeDraw(self.rootNode, res, frustum, camPos, NO, NO);
	//[self.rootNode drawWithMatrix:res frustum:frustum camPos:camPos nonSolid:NO];
	
	glDepthRangef(0.0f, 0.5f);
	[self.cubeMap updateWithTimestep:dt];
	//glActiveTexture(GL_TEXTURE1);
	//glBindTexture(GL_TEXTURE_2D, self.lightMapTexMap.lightMapTexID);
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
	[actors_ release];
	actors_ = nil;
	[classes_ release];
	classes_ = nil;
	if(rootNode_){
		UNRNodeDelete(rootNode_);
		rootNode_ = nil;
	}
	if(meshes_){
		for(int i = 0; i < meshCount_; i++){
			UNRMeshDelete(meshes_[i]);
		}
		free(meshes_);
		meshes_ = NULL;
		meshCount_ = 0;
	}
	if(meshMats_){
		free(meshMats_);
		meshMats_ = NULL;
		meshMatCount_ = 0;
	}
	//[rootNode_ release];
	//rootNode_ = nil;
	[super dealloc];
}

@end
