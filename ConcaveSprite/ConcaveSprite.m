//
//  ConcaveSprite.m
//  ConcaveSprite
//
//  Created by Scott Lembcke on 4/16/13.
//  Copyright 2013 Howling Moon Software. All rights reserved.
//

#import "ConcaveSprite.h"
#import "ChipmunkGLRenderBufferSampler.h"

@implementation ConcaveSprite {
	// Store the mass/density and moment/density to allow them to be changed after init easily.
	cpFloat _normalizedMass;
	cpFloat _normalizedMoment;
}

// Override the designated initializer to set up the physics objects after the CCSprite is ready.
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if((self = [super initWithTexture:texture rect:rect rotated:rotated])){
		_downsample = 1;
		
		// Start with a body with infinite mass and fill it in later.
		ChipmunkBody *body = self.chipmunkBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
		NSMutableArray *chipmunkObjects = [NSMutableArray arrayWithObject:body];
		
		CGRect bounds = self.boundingBox;
		CGSize size = bounds.size;
		cpFloat downsample = self.downsample;
		ChipmunkGLRenderBufferSampler *sampler = [[ChipmunkGLRenderBufferSampler alloc] initWithXSamples:size.width/downsample ySamples:size.height/downsample];
		sampler.renderBounds = bounds;
		[sampler setBorderValue:0.0];
		
		// Render the scene into the renderbuffer so it's ready to be processed
		[sampler renderInto:^{[self visit];}];
		
		// Confusingly, the coordinates returned by the render buffer sampler are in renderbuffer pixel coordinates.
		// These coordinates won't quite line up with Cocos2D points or anything.
		// Setup an affine transform to convert them.
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate(transform, bounds.origin.x, bounds.origin.y);
		transform = CGAffineTransformScale(transform, downsample, downsample);
		
		for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
			// Simplify the line data to ignore details smaller than the downsampling resolution.
			// Because of how the sampler was set up, the units will be in render buffer pixels, not Cocos2D points or pixels.
			ChipmunkPolyline *simplified = [polyline simplifyCurves:1.0f];
			for(ChipmunkPolyline *hull in [simplified toConvexHulls_BETA:1.0]){
				// Annoying step to convert the coordinates.
				cpVect verts[hull.count - 1];
				for(int i=0; i<hull.count - 1; i++){
					verts[i] = CGPointApplyAffineTransform(hull.verts[i], transform);
				}
				
				cpFloat area = cpAreaForPoly(hull.count - 1, verts);
				_normalizedMass += area;
				_normalizedMoment += cpMomentForPoly(area, hull.count - 1, verts, cpvzero);
				
				ChipmunkShape *poly = [ChipmunkPolyShape polyWithBody:body count:hull.count - 1 verts:verts offset:cpvzero];
				[chipmunkObjects addObject:poly];
			}
		}
		
		// Update body with calculated mass and moment.
		self.density = 1.0;
		
		_chipmunkObjects = chipmunkObjects;
	}
	
	return self;
}

-(void)setDensity:(cpFloat)density
{
	_density = density;
	self.chipmunkBody.mass = _normalizedMass*density;
	self.chipmunkBody.moment = _normalizedMoment*density;
}

// You could make similar post-setup setters for other values you wanted to change.
-(void)setElasticity:(cpFloat)elasticity
{
	_elasticity = elasticity;
	
	SEL sel = @selector(setElasticity:);
	for(id obj in self.chipmunkObjects){
		if([obj respondsToSelector:sel]) [obj setElasticity:elasticity];
	}
}

@end
