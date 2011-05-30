//
//  UNRFile.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"

@class UNRName, UNRImport, UNRExport, UNRBase, UNRGuid, UNRGeneration, UNRDataPluginLoader;

@interface UNRFile : NSObject {
	
}

- (id)initWithFileData:(NSData *)fileData pluginsDirectory:(NSString *)path;

- (id)resolveObjectReference:(int)ref;
+ (int)readCompactIndex:(DataManager *)manager;

/*- (NSData *)dataFromFile;
+ (NSData *)writeCompactIndex:(int)index;*/

- (NSUInteger)nameCount;
- (NSUInteger)objectCount;
- (NSUInteger)referenceCount;

- (void)resolveImportReferences:(NSString *)path;

@property(nonatomic, copy) NSNumber *version, *licensee, *flags;
@property(nonatomic, retain) NSMutableArray *objects, *names, *references;
@property(nonatomic, retain) NSMutableArray *generations;
@property(nonatomic, retain) UNRDataPluginLoader *pluginLoader;

@end
