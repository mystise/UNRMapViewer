//
//  UNRObject.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRObject.h"
#import "UNRScriptParser.h"

@implementation UNRObject

@synthesize file = file_, obj = obj_, manager = manager_, currentCommands = currentCommands_, currentArray = currentArray_, currentData = currentData_;

#pragma mark Init Methods

- (id)initWithFile:(UNRFile *)newFile object:(UNRExport *)newObj{
	self = [super init];
	if(self){
		self.currentData = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionary]];
		self.currentArray = [NSMutableArray array];
		self.currentCommands = [NSMutableArray array];
		self.file = newFile;
		self.obj = newObj;
		DataManager *manager = [[DataManager alloc] initWithFileData:newObj.data];
		self.manager = manager;
		[manager release];
		manager = nil;
	}
	return self;
}

#pragma mark Data Methods

- (void)addByteWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addByteWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithUnsignedChar:[self.manager loadByte]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addShortWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addShortWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithShort:[self.manager loadShort]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addIntWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addIntWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithInt:[self.manager loadInt]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addLongWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addLongWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithLongLong:[self.manager loadLong]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addFloatWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addFloatWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithFloat:[self.manager loadFloat]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addPropertiesWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addPropertiesWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSMutableDictionary *value = [NSMutableDictionary dictionary];
		UNRProperty *prop = [[UNRProperty alloc] initWithManager:self.manager file:self.file];
		while(prop){
			[value setObject:prop forKey:prop.name.string];
			[prop release];
			prop = [[UNRProperty alloc] initWithManager:self.manager file:self.file];
		}
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addCompactIndexWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addCompactIndexWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSNumber *value = [NSNumber numberWithInt:[UNRFile readCompactIndex:self.manager]];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addStringWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addStringWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		NSMutableString *value = [NSMutableString string];
		int length = [[current valueForKey:[attrib valueForKey:@"length"]] intValue];
		for(int i = 0; i < length; i++){
			[value appendFormat:@"%c", [self.manager loadByte]];
		}
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addDataWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addDataWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int size = [[current valueForKey:[attrib valueForKey:@"size"]] intValue];
		if(size < 0){
			printf("Data Error!!!!!!\n");
		}
		NSData *value = [NSData dataWithData:[self.obj.data subdataWithRange:NSMakeRange(self.manager.curPos, size)]];
		self.manager.curPos += size;
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addObjectReferenceWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addObjectReferenceWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int compact = [UNRFile readCompactIndex:self.manager];
		UNRBase *value = [self.file resolveObjectReference:compact];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addNameReferenceWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addNameReferenceWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int compact = [UNRFile readCompactIndex:self.manager];
		UNRName *value = [self.file.names objectAtIndex:compact];
		[current setValue:value forKey:[attrib valueForKey:@"name"]];
	}
}

#pragma mark Special Data Methods

- (void)addIntVectorWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addIntVectorWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int vec = [self.manager loadInt];
		float vecX = (vec & 0x7FF);
		vecX /= 8;
		if(vecX > 128){
			vecX -= 256;
		}
		vecX = -vecX;
		float vecY = ((vec >> 11) & 0x7FF);
		vecY /= 8;
		if(vecY > 128){
			vecY -= 256;
		}
		vecY = -vecY;
		float vecZ = ((vec >> 22) & 0x3FF);
		vecZ /= 4;
		if(vecZ > 128){
			vecZ -= 256;
		}
		NSMutableDictionary *vector = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithFloat:vecX], @"x",
									   [NSNumber numberWithFloat:vecY], @"y",
									   [NSNumber numberWithFloat:vecZ], @"z",
									   nil];
		[current setValue:vector forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addVectorWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addVectorWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		float vecX = [self.manager loadFloat];
		float vecY = [self.manager loadFloat];
		float vecZ = [self.manager loadFloat];
		NSDictionary *vector = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithFloat:vecX], @"x",
								[NSNumber numberWithFloat:vecY], @"y",
								[NSNumber numberWithFloat:vecZ], @"z",
								nil];
		[current setValue:vector forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addPlaneWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addPlaneWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		float vecX = [self.manager loadFloat];
		float vecY = [self.manager loadFloat];
		float vecZ = [self.manager loadFloat];
		float vecW = [self.manager loadFloat];
		NSDictionary *plane = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithFloat:vecX], @"x",
							   [NSNumber numberWithFloat:vecY], @"y",
							   [NSNumber numberWithFloat:vecZ], @"z",
							   [NSNumber numberWithFloat:vecW], @"w",
							   nil];
		[current setValue:plane forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addSphereWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addSphereWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		float vecX = [self.manager loadFloat];
		float vecY = [self.manager loadFloat];
		float vecZ = [self.manager loadFloat];
		NSDictionary *sphere;
		if([self.file.version intValue] > 61){
			float vecW = [self.manager loadFloat];
			sphere = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithFloat:vecX], @"x",
					  [NSNumber numberWithFloat:vecY], @"y",
					  [NSNumber numberWithFloat:vecZ], @"z",
					  [NSNumber numberWithFloat:vecW], @"w",
					  nil];
		}else{
			sphere = [NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithFloat:vecX], @"x",
					  [NSNumber numberWithFloat:vecY], @"y",
					  [NSNumber numberWithFloat:vecZ], @"z",
					  nil];
		}
		[current setValue:sphere forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addBoxWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addBoxWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		float vecX1 = [self.manager loadFloat];
		float vecY1 = [self.manager loadFloat];
		float vecZ1 = [self.manager loadFloat];
		float vecX2 = [self.manager loadFloat];
		float vecY2 = [self.manager loadFloat];
		float vecZ2 = [self.manager loadFloat];
		Byte boxIsValid = [self.manager loadByte];
		NSDictionary *box = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:vecX1], @"x",
							  [NSNumber numberWithFloat:vecY1], @"y",
							  [NSNumber numberWithFloat:vecZ1], @"z", nil], @"min",
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:vecX2], @"x",
							  [NSNumber numberWithFloat:vecY2], @"y",
							  [NSNumber numberWithFloat:vecZ2], @"z", nil], @"max",
							 [NSNumber numberWithUnsignedChar:boxIsValid], @"isValid",
							 nil];
		[current setValue:box forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addRotatorWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addRotatorWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		float rotPitch = [self.manager loadInt];
		float rotYaw = [self.manager loadInt];
		float rotRoll = [self.manager loadInt];
		NSDictionary *vector = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithFloat:rotPitch], @"pitch",
								[NSNumber numberWithFloat:rotYaw], @"yaw",
								[NSNumber numberWithFloat:rotRoll], @"roll",
								nil];
		[current setValue:vector forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addGuidWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addScriptWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		UNRGuid *guid = [UNRGuid guidWithManager:self.manager];
		[current setValue:guid forKey:[attrib valueForKey:@"name"]];
	}
}

- (void)addScriptWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"addScriptWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int size = 0;
		if([current valueForKey:[attrib valueForKey:@"size"]]){
			size = [[current valueForKey:[attrib valueForKey:@"size"]] intValue];
		}
		NSMutableData *scriptData = loadScript(self, size);
		
		[current setValue:scriptData forKey:[attrib valueForKey:@"name"]];
	}
}

#pragma mark Array Methods

- (void)beginArrayWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"beginArrayWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		int capacity = [[current valueForKey:[attrib valueForKey:@"count"]] intValue];
		NSMutableArray *value = [NSMutableArray array];
		[[self.currentData lastObject] setValue:value forKey:[attrib valueForKey:@"name"]];
		
		if(capacity > 0){
			[self.currentArray addObject:value];
			NSMutableDictionary *theData = [NSMutableDictionary dictionary];
			[value addObject:theData];
			for(int i = 1; i < capacity; i++){
				[value addObject:[NSNull null]];
			}
			[self.currentArray addObject:[NSNull null]];
			[self.currentData addObject:theData];
		}else{
			[self.currentData addObject:[NSNull null]];
		}
		NSMutableArray *commands = [NSMutableArray array];
		[self.currentCommands addObject:commands];
	}
}

- (void)endArrayWithAttributes:(NSDictionary *)attrib{
	BOOL first = NO;
	if(attrib == nil && [self.currentCommands count] > 0){
		first = YES;
		attrib = (NSDictionary *)[self.currentCommands lastObject];
		[self.currentCommands removeLastObject];
	}
	id current = [self.currentData lastObject];
	[self processArray:@"endArrayWithAttributes:" attribs:attrib];
	if([current isKindOfClass:[NSNull class]]){
		[self.currentData removeLastObject];
	}else if(attrib != nil){
		NSMutableArray *commands = (NSMutableArray *)attrib;
		
		NSDictionary *command; //command - contains methodName and attrib
		NSMutableDictionary *theData; //theData - the new data to add to
		NSString *methodName; //methodName - from command
		NSDictionary *attrib; //attrib - from command
		SEL method; //method - NSSelectorFromString on methodName
		
		[self.currentArray removeLastObject];
		
		int i;
		if(first){
			i = 1;
		}else{
			i = 0;
		}
		for(; i < [[self.currentArray lastObject] count]; i++){
			theData = [NSMutableDictionary dictionary];
			[[self.currentArray lastObject] replaceObjectAtIndex:i withObject:theData];
			[self.currentData addObject:theData];
			for(command in commands){
				methodName = [command valueForKey:@"method"];
				attrib = [command valueForKey:@"attrib"];
				method = NSSelectorFromString(methodName);
				[self performSelector:method withObject:attrib];
			}
			[self.currentData removeLastObject];
		}
		[self.currentArray removeLastObject];
		[self.currentData removeLastObject];
	}
}

- (void)processArray:(NSString *)methodName attribs:(NSDictionary *)attrib{
	if([[self.currentArray lastObject] isKindOfClass:[NSNull class]]){
		NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:
								 methodName, @"method",
								 attrib, @"attrib",
								 nil];
		[[self.currentCommands lastObject] addObject:command];
	}
}

#pragma mark Conditional Methods

- (void)beginConditionalWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"beginConditionalWithAttributes:" attribs:attrib];
	if(![current isKindOfClass:[NSNull class]]){
		id compareObj = [[self.currentData lastObject] valueForKeyPath:[attrib valueForKey:@"objectValue"]];
		BOOL compareSuccess = YES;
		int compare1 = [compareObj intValue];
		if(compareObj == nil){
			compare1 = [[self valueForKeyPath:[attrib valueForKey:@"objectValue"]] intValue];
		}
		NSNumber *compareObj2 = convertStringToObjectFlag([attrib valueForKey:@"compareValue"]);
		int compare2 = [compareObj2 intValue];
		if(compareObj2 == nil){
			compare2 = [[attrib valueForKey:@"compareValue"] intValue];
		}
		NSString *comparator = [attrib valueForKey:@"comparator"];
		if([comparator isEqualToString:@"greater"]){
			if(!(compare1 > compare2)){
				compareSuccess = NO;
			}
		}else if([comparator isEqualToString:@"less"]){
			if(!(compare1 < compare2)){
				compareSuccess = NO;
			}
		}else if([comparator isEqualToString:@"="]){
			if(!(compare1 == compare2)){
				compareSuccess = NO;
			}
		}else if([comparator isEqualToString:@"!="]){
			if(compare1 == compare2){
				compareSuccess = NO;
			}
		}else if([comparator isEqualToString:@"and"]){
			if(!(compare1 & compare2)){
				compareSuccess = NO;
			}
		}
		if(compareSuccess == NO){
			[self.currentData addObject:[NSNull null]];
		}
	}
}

- (void)endConditionalWithAttributes:(NSDictionary *)attrib{
	id current = [self.currentData lastObject];
	[self processArray:@"endConditionalWithAttributes:" attribs:attrib];
	if([current isKindOfClass:[NSNull class]]){
		[self.currentData removeLastObject];
	}
}

- (void)dealloc{
	[file_ release];
	file_ = nil;
	[obj_ release];
	obj_ = nil;
	[manager_ release];
	manager_ = nil;
	[currentArray_ release];
	currentArray_ = nil;
	[currentCommands_ release];
	currentCommands_ = nil;
	[currentData_ release];
	currentData_ = nil;
	[super dealloc];
}

@end
