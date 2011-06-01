//
//  UNRExport.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNRBase.h"

#import "DataManager.h"

@class UNRDataPluginLoader;

@interface UNRExport : UNRBase {
	
}

+ (id)exportWithManager:(DataManager *)manager;
- (void)loadPlugin:(UNRFile *)file;

@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSMutableDictionary *objectData;
@property(nonatomic, copy) NSNumber *flags;
@property(nonatomic, retain) UNRBase *classObj, *superObj;
@property(nonatomic, assign) int classObjRef, superObjRef;
@property(nonatomic, assign) BOOL loading;

@end
