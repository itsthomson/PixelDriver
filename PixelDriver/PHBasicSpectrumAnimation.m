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

#import "PHBasicSpectrumAnimation.h"

@implementation PHBasicSpectrumAnimation {
  PHDegrader* _bassDegrader;
}

- (id)init {
  if ((self = [super init])) {
    _bassDegrader = [[PHDegrader alloc] init];
  }
  return self;
}

- (void)renderBitmapInContext:(CGContextRef)cx size:(CGSize)size {
  if (self.driver.spectrum) {
    [_bassDegrader tickWithPeak:self.driver.subBassAmplitude];

    CGContextSetRGBFillColor(cx, 1, 0, 0, 1);
    CGContextFillRect(cx, CGRectMake(0, 0, _bassDegrader.value * size.width, kWallHeight));
  }
}

@end