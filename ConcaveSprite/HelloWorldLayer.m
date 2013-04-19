/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "HelloWorldLayer.h"
#import "AppDelegate.h"

#import "ConcaveSprite.h"

@implementation HelloWorldLayer {
	ChipmunkSpace *_space;
	CCPhysicsDebugNode *_debugNode;
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	[scene addChild:[HelloWorldLayer node]];
	
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpv(0, -100);
		
		CGRect rect = {CGPointZero, [CCDirector sharedDirector].winSize};
		[_space addBounds:rect thickness:10.0 elasticity:1.0 friction:0.0 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
		
		_debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
		_debugNode.visible = TRUE;
		[self addChild:_debugNode z:1000];
		
		[self addSprite:@"Heart.png" at:ccp(210, 220) isStatic:FALSE];
		[self addSprite:@"Heart.png" at:ccp(270, 220) isStatic:FALSE];
		[self addSprite:@"Star.png" at:ccp(180, 100) isStatic:FALSE];
		[self addSprite:@"Star.png" at:ccp(240, 100) isStatic:TRUE];
		[self addSprite:@"Star.png" at:ccp(300, 100) isStatic:FALSE];
	}
	
	return self;
}

-(void)addSprite:(NSString *)image at:(CGPoint)point isStatic:(bool)isStatic
{
	ConcaveSprite *sprite = [ConcaveSprite spriteWithFile:image];
	sprite.isStatic = isStatic;
	sprite.elasticity = 1.0;
	[sprite setupPhysics];
	
	// NOTE: must call setupPhysics before touching the position property since that sets the chipmunkBody property.
	sprite.position = point;
	[self addChild:sprite];
	[_space add:sprite];
}

-(void)onEnter
{
	[super onEnter];
	
	[self scheduleUpdate];
}

-(void)update:(ccTime)delta
{
	// Just doing a dumb fixed update here...
	[_space step:1.0/60.0];
}

@end
