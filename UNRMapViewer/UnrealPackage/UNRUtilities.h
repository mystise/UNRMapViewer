/*
 *  UNRUtilities.h
 *  UnrealPackageExporter
 *
 *  Created by Adalynn Dudney on 3/4/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define PKGF_allowDownload	0x0001
#define PKGF_clientOptional 0x0002
#define PKGF_serverSideOnly 0x0004
#define PKGF_brokenLinks	0x0008
#define PKGF_unsecure		0x0010
#define PKGF_need			0x8000

#define OF_Transactional	0x00000001
#define OF_Unreachable		0x00000002
#define OF_Public			0x00000004
#define OF_TempImport		0x00000008
#define OF_TempExport		0x00000010
#define OF_SourceModified	0x00000020
#define OF_TagGarbage		0x00000040
#define OF_NeedLoad			0x00000200
#define OF_HighlightedName	0x00000400
#define OF_InSingularFunc	0x00000800
#define OF_Suppress			0x00001000
#define OF_InEndState		0x00002000
#define OF_Transient		0x00004000
#define OF_PreLoading		0x00008000
#define OF_LoadForClient	0x00010000
#define OF_LoadForServer	0x00020000
#define OF_LoadForEdit		0x00040000
#define OF_Standalone		0x00080000
#define OF_NotForClient		0x00100000
#define OF_NotForServer		0x00200000
#define OF_NotForEdit		0x00400000
#define OF_Destroyed		0x00800000
#define OF_NeedPostLoad		0x01000000
#define OF_HasStack			0x02000000
#define OF_Native			0x04000000
#define OF_Marked			0x08000000
#define OF_ErrorShutdown	0x10000000
#define OF_DebugPostLoad	0x20000000
#define OF_DebugSerialize	0x40000000
#define OF_DebugDestroy		0x80000000

#ifndef UNRUtilities
#define UNRUtilities

NSNumber *convertStringToObjectFlag(NSString *string);

#endif

//TODO: remember that unreal uses inverted Y axis with the Z axis as height (like blender)