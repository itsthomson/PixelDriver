//
// Copyright 2012 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "PHNyanCatFgAnimation.h"

#define VOLUME_THRESHOLD 0.1

static const NSTimeInterval kMinimumAnimationChangeInterval = 1;
static const NSTimeInterval kMinimumDelayBetweenHits = 0.1;
static const NSTimeInterval kTimeUntilSleeping = 4;

@implementation PHNyanCatFgAnimation {
    PHSpritesheet* _nyancatSpritesheet;
    
    PHSpriteAnimation* _idleAnimation;
    PHSpriteAnimation* _runningAnimation;
    
    PHSpriteAnimation* _activeAnimation;
    NSTimeInterval _nextAllowedAnimationChangeTime;
    NSTimeInterval _nextSleepTime;
    
    CGFloat _hihatAbsorber;
    CGFloat _vocalAbsorber;
}

- (id)init {
    if ((self = [super init])) {
        _nyancatSpritesheet = [[PHSpritesheet alloc] initWithName:@"nyancat" spriteSize:CGSizeMake(48, 32)];
        
        _idleAnimation = [[PHSpriteAnimation alloc] initWithSpritesheet:_nyancatSpritesheet];
        [_idleAnimation addStillFrameAtX:6 y:0];
        _idleAnimation.repeats = YES;
        _idleAnimation.bounces = NO;
        _idleAnimation.rightBoundary = 1;
        
        _runningAnimation = [[PHSpriteAnimation alloc] initWithSpritesheet:_nyancatSpritesheet];
        [_runningAnimation addFrameAtX:5 y:0 duration:kMinimumDelayBetweenHits];
        [_runningAnimation addFrameAtX:4 y:0 duration:kMinimumDelayBetweenHits];
        [_runningAnimation addFrameAtX:3 y:0 duration:kMinimumDelayBetweenHits];
        [_runningAnimation addFrameAtX:2 y:0 duration:kMinimumDelayBetweenHits];
        [_runningAnimation addFrameAtX:1 y:0 duration:kMinimumDelayBetweenHits];
        [_runningAnimation addFrameAtX:0 y:0 duration:kMinimumDelayBetweenHits];
        _runningAnimation.repeats = YES;
        _runningAnimation.bounces = NO;
        
        _activeAnimation = _idleAnimation;
    }
    return self;
}

- (void)renderBitmapInContext:(CGContextRef)cx size:(CGSize)size {
    if (self.driver.unifiedSpectrum) {
        _hihatAbsorber = _hihatAbsorber * 0.99 + self.driver.hihatAmplitude * 0.01;
        _vocalAbsorber = _vocalAbsorber * 0.99 + self.driver.vocalAmplitude * 0.01;
        
        if (self.driver.hihatAmplitude < VOLUME_THRESHOLD &&
            self.driver.subBassAmplitude < VOLUME_THRESHOLD &&
            self.driver.vocalAmplitude < VOLUME_THRESHOLD &&
            self.driver.snareAmplitude < VOLUME_THRESHOLD) {
            _activeAnimation = _idleAnimation;
        } else if (self.driver.hihatAmplitude > 2 * VOLUME_THRESHOLD ||
                   self.driver.subBassAmplitude > 2 * VOLUME_THRESHOLD ||
                   self.driver.vocalAmplitude > 2 * VOLUME_THRESHOLD ||
                   self.driver.snareAmplitude > 2 * VOLUME_THRESHOLD) {
            _activeAnimation = _runningAnimation;
        }
        
        CGSize size = _nyancatSpritesheet.spriteSize;
        
        CGImageRef imageRef = nil;
        imageRef = [_activeAnimation imageRefAtCurrentTick];
        CGContextDrawImage(cx, CGRectMake(0, 0, size.width, size.height), imageRef);
        
        CGImageRelease(imageRef);
    }
}

@end
