//
//  UNRNode.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

//#import "UNRZone.h"

#import "Matrix3D.h"
#import "Vector4D.h"
#import "Vector3D.h"
#import "Vector2D.h"

@class UNRFile, UNRTexture, UNRShader, UNRMap, UNRBoundingBox;//UNRZone

@interface UNRNode : NSObject {
	
}

- (id)initWithModel:(NSMutableDictionary *)model attributes:(NSMutableDictionary *)attrib;//nodeNumber:(int)nodeNum file:(UNRFile *)file map:(UNRMap *)map

- (void)drawWithMatrix:(Matrix3D)mat camPos:(Vector3D)camPos nonSolid:(BOOL)nonSolid; //rootNode
- (void)drawWithState:(NSMutableDictionary *)state matrix:(Matrix3D)mat camPos:(Vector3D *)camPos; //any subNode

//- (UNRZone *)zoneForCamera:(Vector3D)camPos;

- (void)setupState:(NSMutableDictionary *)state;

@property(nonatomic, assign) int vertCount;
@property(nonatomic, assign) GLuint vbo, vao;
@property(nonatomic, assign) Vector3D normal, origin;
@property(nonatomic, assign) Vector4D plane;
@property(nonatomic, assign) int surfFlags;
@property(nonatomic, assign) int strideLength;

//@property(nonatomic, retain) UNRZone *frontZone, *backZone;
@property(nonatomic, retain) UNRTexture *tex, *lightMap;
@property(nonatomic, retain) UNRNode *front, *back, *coPlanar;
@property(nonatomic, retain) UNRShader *shader;
@property(nonatomic, retain) UNRBoundingBox *renderBox;

@end

//Note: ripped out of Unreal public headers
// Flags describing effects and properties of a Bsp polygon.
enum EPolyFlags{
	// Regular in-game flags.
	PF_Invisible		= 0x00000001,	// Poly is invisible.
	PF_Masked			= 0x00000002,	// Poly should be drawn masked.
	PF_Translucent	 	= 0x00000004,	// Poly is transparent.
	PF_NotSolid			= 0x00000008,	// Poly is not solid, doesn't block.
	PF_Environment   	= 0x00000010,	// Poly should be drawn environment mapped.
	PF_Semisolid	  	= 0x00000020,	// Poly is semi-solid = collision solid, Csg nonsolid.
	PF_Modulated 		= 0x00000040,	// Modulation transparency.
	PF_FakeBackdrop		= 0x00000080,	// Poly looks exactly like backdrop.
	PF_TwoSided			= 0x00000100,	// Poly is visible from both sides.
	PF_AutoUPan		 	= 0x00000200,	// Automatically pans in U direction.
	PF_AutoVPan 		= 0x00000400,	// Automatically pans in V direction.
	PF_NoSmooth			= 0x00000800,	// Don't smooth textures.
	PF_BigWavy 			= 0x00001000,	// Poly has a big wavy pattern in it.
	PF_SmallWavy		= 0x00002000,	// Small wavy pattern (for water/enviro reflection).
	PF_Flat				= 0x00004000,	// Flat surface.
	PF_LowShadowDetail	= 0x00008000,	// Low detaul shadows.
	PF_NoMerge			= 0x00010000,	// Don't merge poly's nodes before lighting when rendering.
	PF_CloudWavy		= 0x00020000,	// Polygon appears wavy like clouds.
	PF_DirtyShadows		= 0x00040000,	// Dirty shadows.
	PF_BrightCorners	= 0x00080000,	// Brighten convex corners.
	PF_SpecialLit		= 0x00100000,	// Only speciallit lights apply to this poly.
	PF_Gouraud			= 0x00200000,	// Gouraud shaded.
	PF_Unlit			= 0x00400000,	// Unlit.
	PF_HighShadowDetail	= 0x00800000,	// High detail shadows.
	PF_Portal			= 0x04000000,	// Portal between iZones.
	PF_Mirrored			= 0x08000000,	// Reflective surface.
	PF_RenderFog		= 0x40000000,	// Render with fogmapping.
	PF_Occlude			= 0x80000000,	// Occludes even if PF_NoOcclude.
	
	// Combinations of flags.
	PF_NoOcclude		= PF_Masked | PF_Translucent | PF_Invisible | PF_Modulated,
	PF_AddLast			= PF_Semisolid | PF_NotSolid,
	PF_NoShadows		= PF_Unlit | PF_Invisible | PF_Environment | PF_FakeBackdrop,
};