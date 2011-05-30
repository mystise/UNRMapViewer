//
//  UNRNode.h
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UNRFile;

@interface UNRNode : NSObject {
	
}

- (id)initWithModel:(NSMutableDictionary *)model nodeNumber:(int)nodeNum file:(UNRFile *)file;

@property(nonatomic, retain) NSArray *verts;
@property(nonatomic, retain) NSDictionary *normal;
@property(nonatomic, retain) NSDictionary *plane;
@property(nonatomic, retain) UNRNode *front, *back, *coPlanar;
//visibility stuff

@end
