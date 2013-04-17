//
//  ConcaveSprite.h
//  ConcaveSprite
//
//  Created by Scott Lembcke on 4/16/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface ConcaveSprite : CCPhysicsSprite <ChipmunkObject>

@property(nonatomic, readonly) NSArray *chipmunkObjects;

@property(nonatomic, assign) unsigned int downsample;
@property(nonatomic, assign) cpFloat density;
@property(nonatomic, assign) cpFloat elasticity;

@end
