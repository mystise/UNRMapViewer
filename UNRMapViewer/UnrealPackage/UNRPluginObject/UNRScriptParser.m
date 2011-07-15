//
//  UNRScriptParser.c
//  UnrealPackageExporter
//
//  Created by Adalynn Dudney on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UNRScriptParser.h"
#import "UNRObject.h"

Byte loadToken(UNRObject *self, NSMutableData *scriptData, BOOL *done){
	Byte token = [self.manager loadByte];
	[scriptData appendBytes:&token length:sizeof(Byte)];
	switch(token){
		case 0:{//Local Variable
			unsigned int objectRef = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&objectRef length:sizeof(unsigned int)];
			break;
		}
		case 1:{//Instance Variable
			unsigned int objectRef = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&objectRef length:sizeof(unsigned int)];
			break;
		}
		case 2:{//Default Variable
			unsigned int objectRef = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&objectRef length:sizeof(unsigned int)];
			break;
		}
		case 3:{//unknown
			unsigned int objectRef = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&objectRef length:sizeof(unsigned int)];
			break;
		}
		case 4:{//Returns next token
			break;
		}
		case 5:{//switch, switches based on next token
			Byte switchSize = [self.manager loadByte];
			[scriptData appendBytes:&switchSize length:sizeof(Byte)];
			break;
		}
		case 6:{//goto
			short location = [self.manager loadShort];
			[scriptData appendBytes:&location length:sizeof(short)];
			break;
		}
		case 7:{//goto if not, goto's if the next token evaluates to false
			short location = [self.manager loadShort];
			[scriptData appendBytes:&location length:sizeof(short)];
			break;
		}
		case 8:{//stop
			if(loadToken(self, scriptData, done) != 12){
				printf("Error!!!");
			}
			break;
		}
		case 9:{//asserts based on the result of the next token
			short line = [self.manager loadShort];
			[scriptData appendBytes:&line length:sizeof(short)];
			break;
		}
		case 10:{//switch case
			Byte nextOffset = [self.manager loadByte];
			[scriptData appendBytes:&nextOffset length:sizeof(short)];
			if(nextOffset != 0xFF){
				//next token is the value in the switch case
			}
			break;
		}
		case 11:{//empty token
			break;
		}
		case 12:{//label table
			unsigned int curPos = self.manager.curPos;
			int nameIndex = [UNRFile readCompactIndex:self.manager];
			int offset = [self.manager loadInt];
			[scriptData appendBytes:&nameIndex length:sizeof(int)];
			[scriptData appendBytes:&offset length:sizeof(int)];
			int length = self.manager.curPos - curPos;
			while(![[[[self.file.names objectAtIndex:nameIndex] string] lowercaseString] isEqualToString:@"none"]){
				curPos = self.manager.curPos;
				
				nameIndex = [UNRFile readCompactIndex:self.manager];
				offset = [self.manager loadInt];
				[scriptData appendBytes:&nameIndex length:sizeof(int)];
				[scriptData appendBytes:&offset length:sizeof(int)];
				
				length += self.manager.curPos - curPos;
				
				if(nameIndex < 0){
					break;
				}
			}
			length %= 4;
			for(int i = 0; i < length; i++){
				Byte dat = [self.manager loadByte];
				[scriptData appendBytes:&dat length:sizeof(Byte)];
			}
			*done = YES;
			
			break;
		}
		case 13:{//goto label, next token is label
			break;
		}
		case 14:{//eat string (???), next token is string to be eaten
			token = loadToken(self, scriptData, done);
			break;
		}
		case 15:{//assignment, first token after this is set to the value of the second token
			break;
		}
		case 16:{//dynamic array access, first token after this is the index, the second token is the array
			break;
		}
		case 17:{//new, next 4 tokens after this are arguments
			break;
		}
		case 18:{//class context
			loadToken(self, scriptData, done);
			//int class = [UNRFile readCompactIndex:self.manager];
			short wSkip = [self.manager loadShort];
			Byte bSkip = [self.manager loadByte];
			[scriptData appendBytes:&wSkip length:sizeof(short)];
			[scriptData appendBytes:&bSkip length:sizeof(Byte)];
			loadToken(self, scriptData, done);
			//int object = [UNRFile readCompactIndex:self.manager];
			//[scriptData appendBytes:&class length:sizeof(int)];
			//[scriptData appendBytes:&object length:sizeof(int)];
			break;
		}
		case 19:{//class cast, casts the next token to the class specified
			int class = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&class length:sizeof(int)];
			break;
		}
		case 20:{//boolean assignment, assigns the next token to the next next token
			break;
		}
		case 21:{//unknown
			short unk = [self.manager loadShort];
			[scriptData appendBytes:&unk length:sizeof(short)];
			break;
		}
		case 22:{//end function parameters (a close paren)
			break;
		}
		case 23:{//self access
			break;
		}
		case 24:{//skip (maybe it skips the next skipCount tokens?)
			short skipCount = [self.manager loadShort];
			[scriptData appendBytes:&skipCount length:sizeof(short)];
			break;
		}
		case 25:{//context (???)
			loadToken(self, scriptData, done);
			//int class = [UNRFile readCompactIndex:self.manager];
			short wSkip = [self.manager loadShort];
			Byte bSkip = [self.manager loadByte];
			[scriptData appendBytes:&wSkip length:sizeof(short)];
			[scriptData appendBytes:&bSkip length:sizeof(Byte)];
			loadToken(self, scriptData, done);
			//int object = [UNRFile readCompactIndex:self.manager];
			//[scriptData appendBytes:&class length:sizeof(int)];
			//[scriptData appendBytes:&object length:sizeof(int)];
			break;
		}
		case 26:{//constant array access, next token is address, next next token is array
			break;
		}
		case 27:{//virtual function call, parameters follow until the close paren
			int nameIndex = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&nameIndex length:sizeof(int)];
			break;
		}
		case 28:{//final function call, parameters follow until the close paren
			int nameIndex = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&nameIndex length:sizeof(int)];
			break;
		}
		case 29:{//int constant
			int constant = [self.manager loadInt];
			[scriptData appendBytes:&constant length:sizeof(int)];
			break;
		}
		case 30:{//float constant
			float constant = [self.manager loadFloat];
			[scriptData appendBytes:&constant length:sizeof(float)];
			break;
		}
		case 31:{//string constant
			char constant = [self.manager loadByte];
			while(constant != 0x00){
				[scriptData appendBytes:&constant length:sizeof(Byte)];
				constant = [self.manager loadByte];
			}
			break;
		}
		case 32:{//object constant
			int constant = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&constant length:sizeof(int)];
			break;
		}
		case 33:{//name constant
			int constant = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&constant length:sizeof(int)];
			break;
		}
		case 34:{//rotation constant
			int pitch = [self.manager loadInt];
			int yaw = [self.manager loadInt];
			int roll = [self.manager loadInt];
			[scriptData appendBytes:&pitch length:sizeof(int)];
			[scriptData appendBytes:&yaw length:sizeof(int)];
			[scriptData appendBytes:&roll length:sizeof(int)];
			break;
		}
		case 35:{//vector constant
			float x = [self.manager loadFloat];
			float y = [self.manager loadFloat];
			float z = [self.manager loadFloat];
			[scriptData appendBytes:&x length:sizeof(float)];
			[scriptData appendBytes:&y length:sizeof(float)];
			[scriptData appendBytes:&z length:sizeof(float)];
			break;
		}
		case 36:{//Byte cont (???)
			//Byte unk = [self.manager loadByte];
			//[scriptData appendBytes:&unk length:sizeof(Byte)];
			break;
		}
		case 37:{//int zero (constant 0)
			break;
		}
		case 38:{//int one (constant 1)
			break;
		}
		case 39:{//bool true (constant 1)
			break;
		}
		case 40:{//bool false (constant 0)
			break;
		}
		case 41:{//native parameter
			int param = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&param length:sizeof(int)];
			break;
		}
		case 42:{//no object (constant None)
			break;
		}
		case 43:{//unknown, possibly type cast
			Byte unk = [self.manager loadByte];
			[scriptData appendBytes:&unk length:sizeof(Byte)];
			break;
		}
		case 44:{//int const byte (???) next token is the value
			Byte unk = [self.manager loadByte];
			[scriptData appendBytes:&unk length:sizeof(Byte)];
			break;
		}
		case 45:{//bool var, next token is the value
			break;
		}
		case 46:{//dynamic cast
			int object = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&object length:sizeof(int)];
			break;
		}
		case 47:{//iterator begin
			loadToken(self, scriptData, done);
			short offset = [self.manager loadShort];
			[scriptData appendBytes:&offset length:sizeof(short)];
			break;
		}
		case 48:{//iterator pop, happens before iterator next
			break;
		}
		case 49:{//iterator next, (close brace), loops around
			break;
		}
		case 50:{//struct compare, checks if the next two tokens are equal to each other
			int structType = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&structType length:sizeof(int)];
			break;
		}
		case 51:{//struct compare not equal, checks if the next two tokens are not equal to each other
			int structType = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&structType length:sizeof(int)];
			break;
		}
		case 52:{//unicode string
			printf("Ack! unicode!\n");
			break;
		}
		case 54:{//struct access, next token is the struct
			int member = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&member length:sizeof(int)];
			break;
		}
		case 55:{//unknown
			break;
		}
		case 56:{//global function call, parameters follow until the close paren
			int nameIndex = [UNRFile readCompactIndex:self.manager];
			[scriptData appendBytes:&nameIndex length:sizeof(int)];
			break;
		}
			//... merely a definition of casts
		default:
			if(token < 0x60 && !(token < 0x5A && token > 0x38) && !(token > 0x59)){
				printf("Unknown Token: %X\n", token);
			}
			break;
	}
	if(token >= 0x60){
		short function = token;
		if(token < 0x70){
			function = (token & 0x0F) << 8 | [self.manager loadByte];
		}
		printf("Native function: %i\n", function);
	}
	return token;
}

NSMutableData *loadScript(UNRObject *self, int size){
	NSMutableData *scriptData = [NSMutableData data];
	printf("UNRScript:\n");
	//loop over the data, loading as you go, and add to scriptData
	if(size > 0){
		BOOL done = NO;
		while(!done){
			printf("\t%X\n", loadToken(self, scriptData, &done));
			if([scriptData length] >= size){
				done = YES;
			}
		}
	}
	printf("\n\n");
	return scriptData;
}