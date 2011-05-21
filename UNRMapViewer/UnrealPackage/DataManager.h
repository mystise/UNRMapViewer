//
//  DataManager.h
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject {
	NSData *fileData;
	unsigned int curPos;
}

- (id)initWithFileData:(NSData *)data;
- (unsigned int)distanceToEOF;
- (BOOL)endOfFile;

- (Byte)loadByte;
- (short)loadShort;
- (int)loadInt;
- (long)loadLong;
- (float)loadFloat;

@property(nonatomic, readonly) NSData *fileData;
@property(nonatomic, assign) unsigned int curPos;

@end
