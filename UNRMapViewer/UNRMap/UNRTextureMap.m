//
//  UNRTextureMap.m
//  UNRMapViewer
//
//  Created by Bill Dudney on 7/16/11.
//  Copyright 2011 Gala Factory Software LLC. All rights reserved.
//

#import "UNRTextureMap.h"
#import "UNRTexture.h"
#import "UNRNode.h"
#import "UNRShader.h"

struct UNRTextureMapNode;

typedef struct UNRTextureMapNode {
  CGRect rect;
  UNRNode *unrNode;
//  UNRTexture *texture;
  struct UNRTextureMapNode *children[2];
} UNRTextureMapNode;

UNRTextureMapNode *InsertTextureIntoMapNode(UNRTextureMapNode *node, UNRNode *unrNode);
void AddTexturesFromNode(UNRTextureMapNode *mapNode, struct UNRNode *node);
void TexSubImage(UNRTextureMapNode *mapNode, CGSize texMapSize);
NSMutableString *DescribeMapNode(UNRTextureMapNode *mapNode, NSMutableString *string);

@implementation UNRTextureMap {
  UNRTextureMapNode *rootNode;
}

@synthesize size = size_;
@synthesize lightMapTexID = lightMapTexID;

- (id)initWithSize:(CGSize)size {
  self = [super init];
  if(nil != self) {
    rootNode = calloc(1, sizeof(UNRTextureMapNode));
    rootNode->rect = CGRectMake(0.0, 0.0, size.width, size.height);
    self.size = size;
  }
  return self;
}

- (void)addTexturesFromNode:(struct UNRNode *)node {
  AddTexturesFromNode(rootNode, node);
}

- (void)uploadToGPU {
  GLuint texture;
  glGenTextures(1, &texture);
  self.lightMapTexID = texture;
  glBindTexture(GL_TEXTURE_2D, texture);

  void *data = calloc(self.size.width * self.size.height, 4 * sizeof(Byte));
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.size.width, self.size.height, 0,
               GL_RGBA, GL_UNSIGNED_BYTE, data);
  free(data);
  
  TexSubImage(rootNode, self.size);
}

- (NSString *)description {
  NSMutableString *string = [[[NSMutableString alloc] init] autorelease];
  return [[DescribeMapNode(rootNode, string) copy] autorelease];
}

@end

void TexSubImage(UNRTextureMapNode *mapNode, CGSize texMapSize) {
  if(NULL != mapNode->unrNode) {
    if(NULL != mapNode->unrNode->lightMapCoords) {
      NSLog(@"mapNode->rect = %@", NSStringFromCGRect(mapNode->rect));
      glTexSubImage2D(GL_TEXTURE_2D, 0, CGRectGetMinX(mapNode->rect), CGRectGetMinY(mapNode->rect),
                      CGRectGetWidth(mapNode->rect), CGRectGetHeight(mapNode->rect),
                      GL_RGBA, GL_UNSIGNED_BYTE, [[mapNode->unrNode->lightMap textureData] bytes]);
      for(int i = 0;i < mapNode->unrNode->vertCount;i++) {
        Vector2D lightMapCoord = mapNode->unrNode->lightMapCoords[i];
        lightMapCoord.x = (lightMapCoord.x * (mapNode->rect.size.width / texMapSize.width)) + (mapNode->rect.origin.x / texMapSize.width);
        lightMapCoord.y = (lightMapCoord.y * (mapNode->rect.size.height / texMapSize.height)) + (mapNode->rect.origin.y / texMapSize.height);
        mapNode->unrNode->lightMapCoords[i] = lightMapCoord;
      }
      glBindVertexArrayOES(mapNode->unrNode->vao);
      GLuint gak = 0;
      glGenBuffers(1, &gak);
      mapNode->unrNode->lightMapVBO = gak;
      glBindBuffer(GL_ARRAY_BUFFER, mapNode->unrNode->lightMapVBO);
      glBufferData(GL_ARRAY_BUFFER, mapNode->unrNode->vertCount * sizeof(Vector2D), mapNode->unrNode->lightMapCoords, GL_STATIC_DRAW);
      GLuint inLightCoord = [mapNode->unrNode->shader attribLocation:@"inLightCoord"];
      glEnableVertexAttribArray(inLightCoord);
      glVertexAttribPointer(inLightCoord, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    }
  }
  if(NULL != mapNode->children[0]) {
    TexSubImage(mapNode->children[0], texMapSize);
  }
  if(NULL != mapNode->children[1]) {
    TexSubImage(mapNode->children[1], texMapSize);
  }
}

NSMutableString *DescribeMapNode(UNRTextureMapNode *mapNode, NSMutableString *string) {
  if(NULL != mapNode) {
    [string appendFormat:@"{rect = %@", NSStringFromCGRect(mapNode->rect)];
    if(NULL != mapNode->children[0] && NULL != mapNode->children[1]) {
      [string appendFormat:@" {right "];
      DescribeMapNode(mapNode->children[0], string);
      [string appendFormat:@"}, {left "];
      DescribeMapNode(mapNode->children[1], string);  
      [string appendFormat:@"}"];
    }
    [string appendFormat:@"}"];
  }
  
  return string;
}

void AddTexturesFromNode(UNRTextureMapNode *mapNode, struct UNRNode *node) {
  InsertTextureIntoMapNode(mapNode, node);
  if(NULL != node->coPlanar) {
    AddTexturesFromNode(mapNode, node->coPlanar);
  }
  if(NULL != node->front) {
    AddTexturesFromNode(mapNode, node->front);
  }
  if(NULL != node->back) {
    AddTexturesFromNode(mapNode, node->back);
  }
}

UNRTextureMapNode *InsertTextureIntoMapNode(UNRTextureMapNode *node, struct UNRNode *unrNode) {
  UNRTextureMapNode *insertedNode = NULL;
  if(NULL == unrNode->lightMap) {
    return insertedNode;
  }
  if(NULL != node->children[0] && NULL != node->children[1]) {
    insertedNode = InsertTextureIntoMapNode(node->children[0], unrNode);
    if(NULL == insertedNode) {
      insertedNode = InsertTextureIntoMapNode(node->children[1], unrNode);
    }
  } else {
    if(NULL != node->unrNode) {
      return NULL;
    }
    if((CGRectGetWidth(node->rect) < unrNode->lightMap.width) || CGRectGetHeight(node->rect) < unrNode->lightMap.height) {
      return NULL;
    }
    if((CGRectGetWidth(node->rect) == unrNode->lightMap.width) && CGRectGetHeight(node->rect) == unrNode->lightMap.height) {
      node->unrNode = unrNode;
      return node;
    }
    
    node->children[0] = (UNRTextureMapNode *)calloc(1, sizeof(UNRTextureMapNode));
    node->children[1] = (UNRTextureMapNode *)calloc(1, sizeof(UNRTextureMapNode));
    
    CGFloat dw = CGRectGetWidth(node->rect) - unrNode->lightMap.width;
    CGFloat dh = CGRectGetHeight(node->rect) - unrNode->lightMap.height;
    
    if(dw > dh) {
      node->children[0]->rect = 
      CGRectMake(CGRectGetMinX(node->rect), CGRectGetMinY(node->rect),
                 unrNode->lightMap.width, CGRectGetHeight(node->rect));
      node->children[1]->rect = 
      CGRectMake(CGRectGetMinX(node->rect) + unrNode->lightMap.width, CGRectGetMinY(node->rect),
                 CGRectGetWidth(node->rect) - unrNode->lightMap.width, CGRectGetHeight(node->rect));
    } else {
      node->children[0]->rect = 
      CGRectMake(CGRectGetMinX(node->rect), CGRectGetMinY(node->rect),
                 CGRectGetWidth(node->rect), unrNode->lightMap.height);
      node->children[1]->rect = 
      CGRectMake(CGRectGetMinX(node->rect), CGRectGetMinY(node->rect) + unrNode->lightMap.height,
                 CGRectGetWidth(node->rect), CGRectGetHeight(node->rect) - unrNode->lightMap.height);
    }
    return InsertTextureIntoMapNode(node->children[0], unrNode);
  }
  return insertedNode;
}
