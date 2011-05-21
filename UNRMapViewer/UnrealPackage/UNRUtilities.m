/*
 *  UNRUtilities.m
 *  UnrealPackageExporter
 *
 *  Created by Adalynn Dudney on 3/4/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "UNRUtilities.h"

NSNumber *convertStringToObjectFlag(NSString *string){
	NSDictionary *objectFlags = [[[NSDictionary alloc] initWithObjectsAndKeys:
								 [NSNumber numberWithInt:0x01],			@"OF_Transactional",
								 [NSNumber numberWithInt:0x02],			@"OF_Unreachable",
								 [NSNumber numberWithInt:0x04],			@"OF_Public",
								 [NSNumber numberWithInt:0x08],			@"OF_TempImport",
								 [NSNumber numberWithInt:0x10],			@"OF_TempExport",
								 [NSNumber numberWithInt:0x20],			@"OF_SourceModified",
								 [NSNumber numberWithInt:0x40],			@"OF_TagGarbage",
								 [NSNumber numberWithInt:0x0200],		@"OF_NeedLoad",
								 [NSNumber numberWithInt:0x0400],		@"OF_HighlightedName",
								 [NSNumber numberWithInt:0x0800],		@"OF_InSingularFunc",
								 [NSNumber numberWithInt:0x1000],		@"OF_Suppress",
								 [NSNumber numberWithInt:0x2000],		@"OF_InEndState",
								 [NSNumber numberWithInt:0x4000],		@"OF_Transient",
								 [NSNumber numberWithInt:0x8000],		@"OF_PreLoading",
								 [NSNumber numberWithInt:0x010000],		@"OF_LoadForClient",
								 [NSNumber numberWithInt:0x020000],		@"OF_LoadForServer",
								 [NSNumber numberWithInt:0x040000],		@"OF_LoadForEdit",
								 [NSNumber numberWithInt:0x080000],		@"OF_Standalone",
								 [NSNumber numberWithInt:0x100000],		@"OF_NotForClient",
								 [NSNumber numberWithInt:0x200000],		@"OF_NotForServer",
								 [NSNumber numberWithInt:0x400000],		@"OF_NotForEdit",
								 [NSNumber numberWithInt:0x800000],		@"OF_Destroyed",
								 [NSNumber numberWithInt:0x01000000],	@"OF_NeedPostLoad",
								 [NSNumber numberWithInt:0x02000000],	@"OF_HasStack",
								 [NSNumber numberWithInt:0x04000000],	@"OF_Native",
								 [NSNumber numberWithInt:0x08000000],	@"OF_Marked",
								 [NSNumber numberWithInt:0x10000000],	@"OF_ErrorShutdown",
								 [NSNumber numberWithInt:0x20000000],	@"OF_DebugPostLoad",
								 [NSNumber numberWithInt:0x40000000],	@"OF_DebugSerialize",
								 [NSNumber numberWithInt:0x80000000],	@"OF_DebugDestroy",
								 nil] autorelease];
	return [objectFlags valueForKey:string];
}