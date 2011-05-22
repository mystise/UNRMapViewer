//
//  UNRDataPluginReader.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UNRObject;

@interface UNRDataPluginReader : NSObject <NSXMLParserDelegate> {
    
}

@property(nonatomic, retain) NSMutableDictionary *plugins;
@property(nonatomic, assign) BOOL addData;
@property(nonatomic, retain) UNRObject *obj;
@property(nonatomic, retain) NSDictionary *dataTypes, *dataEndTypes;

@end
