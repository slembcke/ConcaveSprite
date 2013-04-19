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

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@interface ConcaveSprite : CCPhysicsSprite <ChipmunkObject>

@property(nonatomic, readonly) NSArray *chipmunkObjects;

@property(nonatomic, assign) unsigned int downsample;
@property(nonatomic, assign) bool isStatic;
@property(nonatomic, assign) cpFloat density;
@property(nonatomic, assign) cpFloat elasticity;

// Creates a body and sets up shapes based on the sprite's alpha.
// 'qualityThreshold' is how closely (in points) that the shape should match the original.
// 'concavityThreshold' allows you to control how many convex polygons the final shape is split into.
// This controls how deep a dimple must be in (in points) the surface of a shape to cause it to be split at that point.
// If you want a single convex polygon, you can pass INFINITY for the concavity threshold.
-(void)setupPhysicsWithShapeQuality:(cpFloat)qualityThreshold concavityThreshold:(cpFloat)concavityThreshold;

// Calls the above method with 2.0 for both thresholds.
-(void)setupPhysics;

@end
