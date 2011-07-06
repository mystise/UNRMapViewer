//
//  UNRProperty.m
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRProperty.h"


@implementation UNRProperty

@synthesize name = name_, structName = structName_, special = special_, type = type_, index = index_, manager = manager_, object = object_;

- (id)initWithManager:(DataManager *)manager file:(UNRFile *)newFile{
	self = [super init];
	if(self){
		int backup = manager.curPos;
		int nameRef = [UNRFile readCompactIndex:manager];
		if(nameRef < 0){
			manager.curPos = backup;
			printf("ERROR! property not loaded. %X\n", manager.curPos);
			[self release];
			self = nil;
			return self;
		}
		self.name = [newFile.names objectAtIndex:nameRef];
		if([[self.name.string lowercaseString] isEqualToString:@"none"]){
			[self release];
			self = nil;
			return self;
		}
		Byte info = [manager loadByte];
		self.type = info & 0x0F;
		Byte size = (info >> 4) & 0x07;
		self.special = (info >> 7) & 0x01;
		switch(self.type){
			case 0x0A:
				self.structName = [newFile.names objectAtIndex:[UNRFile readCompactIndex:manager]];
				break;
			default:
				break;
		}		
		int realSize = 0;
		switch(size){
			case 0x00:
				realSize = 1;
				break;
			case 0x01:
				realSize = 2;
				break;
			case 0x02:
				realSize = 4;
				break;
			case 0x03:
				realSize = 12;
				break;
			case 0x04:
				realSize = 16;
				break;
			case 0x05:
				realSize = [manager loadByte];
				break;
			case 0x06:
				realSize = [manager loadShort];
				break;
			case 0x07:
				realSize = [manager loadInt];
				break;
			default:
				break;
		}
		if(self.special == YES && self.type != 0x03){
			self.index = [UNRProperty readIndex:manager];
		}
		if(self.type != 0x03){
			NSData *data = [manager.fileData subdataWithRange:NSMakeRange(manager.curPos, realSize)];
			DataManager *newManager = [[DataManager alloc] initWithFileData:data];
			self.manager = newManager;
			manager.curPos += realSize;
			if(self.type == 0x05){
				self.object = [newFile resolveObjectReference:[UNRFile readCompactIndex:self.manager]];
			}
			self.manager.curPos = 0;
			[newManager release];
		}
	}
	return self;
}

/*- (NSString *)shortDescription{
	NSMutableString *propString = [NSMutableString string];
	switch(self.type){
		case 0x01:
			[propString appendString:@"Byte "];
			break;
		case 0x02:
			[propString appendString:@"int "];
			break;
		case 0x03:
			[propString appendString:@"BOOL "];
			break;
		case 0x04:
			[propString appendString:@"float "];
			break;
		case 0x05:
			[propString appendString:@"Object *"];
			break;
		case 0x06:
			[propString appendString:@"Name *"];
			break;
		case 0x07:
			[propString appendString:@"String "];
			break;
		case 0x08:
			[propString appendString:@"Class "];
			break;
		case 0x09:
			[propString appendString:@"Array "];
			break;
		case 0x0A:
			[propString appendString:@"struct "];
			break;
		case 0x0B:
			[propString appendString:@"Vector "];
			break;
		case 0x0C:
			[propString appendString:@"Rotator "];
			break;
		case 0x0D:
			[propString appendString:@"Str "];
			break;
		case 0x0E:
			[propString appendString:@"Map "];
			break;
		case 0x0F:
			[propString appendString:@"FixedArray "];
			break;
		default:
			[propString appendFormat:@"%X ", self.type];
			break;
	}
	if(self.structName != nil){
		[propString appendFormat:@"%@ ", self.structName.string];
	}
	[propString appendFormat:@"%@", self.name.string];
	if(self.index != 0){
		[propString appendFormat:@"[%i]", self.index];
	}
	return [[propString copy] autorelease];
}

- (NSString *)description{
	NSMutableString *propString = [NSMutableString stringWithString:[self shortDescription]];
	DataManager *manager = [[[DataManager alloc] initWithFileData:self.data] autorelease];
	[propString appendString:@" = "];
	switch(self.type){
		case 0x01://byte
			[propString appendFormat:@"%i;", [manager loadByte]];
			break;
		case 0x02://int
			[propString appendFormat:@"%i;", [manager loadInt]];
			break;
		case 0x03://Bool
			if(self.special){
				[propString appendString:@"True;"];
			}else{
				[propString appendString:@"False;"];
			}
			break;
		case 0x04://float
			[propString appendFormat:@"%f;", [manager loadFloat]];
			break;
		case 0x05://Object
		{
			UNRBase *obj = [self.file resolveObjectReference:[UNRFile readCompactIndex:manager]];
			[propString appendFormat:@"%@;", obj.name.string];
		}
			break;
		case 0x06://Name
			[propString appendFormat:@"%@;", [[self.file.names objectAtIndex:[UNRFile readCompactIndex:manager]] string]];
			break;
		//case 0x07://String
		//	[propString appendString:[[[NSString alloc] initWithBytes:(const void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease]];
		//	break;
		case 0x0D://Str
			[propString appendString:[[[NSString alloc] initWithBytes:(const void *)[[self.data subdataWithRange:NSMakeRange(1, [self.data length]-1)] bytes] length:[self.data length]-1 encoding:NSASCIIStringEncoding] autorelease]];
			break;
		default:
			[propString appendFormat:@"%@;", self.data];
			break;
	}
	return [[propString copy] autorelease];
}*/

+ (int)readIndex:(DataManager *)manager{
	Byte indexByte1 = [manager loadByte];
	int ind = indexByte1 & 0x3F;
	Byte cont = indexByte1 & 0xC0;
	if(cont == 0x80){
		Byte secondByte = [manager loadByte];
		ind = (ind<<6)|secondByte;
	}else if(cont == 0xC0){
		Byte byte1 = [manager loadByte];
		Byte byte2 = [manager loadByte];
		Byte byte3 = [manager loadByte];
		ind = (ind<<6)|byte1;
		ind = (ind<<14)|byte2;
		ind = (ind<<22)|byte3;
	}
	return ind;
}

- (void)dealloc{
	[name_ release];
	name_ = nil;
	[structName_ release];
	structName_ = nil;
	[manager_ release];
	manager_ = nil;
//	[data_ release];
//	data_ = nil;
	[object_ release];
	object_ = nil;
	[super dealloc];
}

@end
