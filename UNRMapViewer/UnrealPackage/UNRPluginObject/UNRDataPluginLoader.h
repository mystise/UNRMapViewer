//
//  PluginLoader.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/8/11.
//  Copyright 2011 ADCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Unreal.h"
#import "DataManager.h"
@class UNRObject;

@interface UNRDataPluginLoader : NSObject <NSXMLParserDelegate> {
	
}

- (id)initWithDirectory:(NSString *)path;

- (void)loadPlugin:(UNRExport *)object file:(UNRFile *)file;

@property(nonatomic, retain) NSMutableDictionary *plugins;
@property(nonatomic, retain) NSURL *url;

@end
