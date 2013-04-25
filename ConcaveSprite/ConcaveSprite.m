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
		_density = 1.0f;
		_elasticity = 0.0f;
	}
	
	return self;
}

-(void)setupPhysics
{
	[self setupPhysicsWithShapeQuality:2.0 concavityThreshold:2.0];
}

-(void)setupPhysicsWithShapeQuality:(cpFloat)qualityThreshold concavityThreshold:(cpFloat)concavityThreshold
{
	// Start with a body with infinite mass and fill it in later.
	ChipmunkBody *body = (self.isStatic ? [ChipmunkBody staticBody] : [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY]);
	self.chipmunkBody = body;
	
	NSMutableArray *chipmunkObjects = [NSMutableArray array];
	
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
	
	cpFloat elasticity = self.elasticity;
	
	for(ChipmunkPolyline *polyline in [sampler marchAllWithBorder:TRUE hard:FALSE]){
		// Simplify the line data to ignore details smaller than the downsampling resolution.
		// Because of how the sampler was set up, the units will be in render buffer pixels, not Cocos2D points or pixels.
		ChipmunkPolyline *simplified = [polyline simplifyCurves:qualityThreshold/_downsample];
		for(ChipmunkPolyline *hull in [simplified toConvexHulls_BETA:concavityThreshold/_downsample]){
			// Annoying step to convert the coordinates.
			cpVect verts[hull.count - 1];
			for(int i=0; i<hull.count - 1; i++){
				verts[i] = CGPointApplyAffineTransform(hull.verts[i], transform);
			}
			
			cpFloat area = cpAreaForPoly(hull.count - 1, verts);
			_normalizedMass += area;
			_normalizedMoment += cpMomentForPoly(area, hull.count - 1, verts, cpvzero);
			
			ChipmunkShape *poly = [ChipmunkPolyShape polyWithBody:body count:hull.count - 1 verts:verts offset:cpvzero];
			poly.elasticity = elasticity;
			[chipmunkObjects addObject:poly];
		}
	}
	
	// Update body with calculated mass and moment.
	if(!self.isStatic){
		[chipmunkObjects addObject:body];
		self.density = _density;
	}
	
	_chipmunkObjects = chipmunkObjects;
}

-(void)setDensity:(cpFloat)density
{
	_density = density;
	self.chipmunkBody.mass = _normalizedMass*density;
	self.chipmunkBody.moment = _normalizedMoment*density;
}

-(void)setSensor:(bool)sensor
{
	_sensor = sensor;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).sensor = sensor;
		}
	}
}

-(void)setElasticity:(cpFloat)elasticity
{
	_elasticity = elasticity;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).elasticity = elasticity;
		}
	}
}

-(void)setFriction:(cpFloat)friction
{
	_friction = friction;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).friction = friction;
		}
	}
}

-(void)setSurfaceVel:(cpVect)surfaceVel
{
	_surfaceVel = surfaceVel;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).surfaceVel = surfaceVel;
		}
	}
}

-(void)setCollisionType:(cpCollisionType)collisionType
{
	_collisionType = collisionType;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).collisionType = collisionType;
		}
	}
}

-(void)setGroup:(cpGroup)group
{
	_group = group;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).group = group;
		}
	}
}

-(void)setLayers:(cpLayers)layers
{
	_layers = layers;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).layers = layers;
		}
	}
}

-(void)setData:(id)data
{
	_data = data;
	
	for(id obj in self.chipmunkObjects){
		if([obj isKindOfClass:[ChipmunkShape class]]){
			((ChipmunkShape *)obj).data = data;
		}
	}
}

@end
