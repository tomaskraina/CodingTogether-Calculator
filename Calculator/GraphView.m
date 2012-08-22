//
//  GraphView.m
//  Calculator
//
//  Created by Tom Kraina on 16.08.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define DEFAULT_ORIGIN_MARGIN 20.0
#define DEFAULT_SCALE 1.0

@implementation GraphView
@synthesize datasource = _datasource;
@synthesize origin = _origin;
@synthesize scale = _scale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGPoint)origin
{
    if (CGPointEqualToPoint(_origin, CGPointZero)) {
        _origin = CGPointMake(DEFAULT_ORIGIN_MARGIN, self.bounds.size.height - DEFAULT_ORIGIN_MARGIN);
    }
    
    return _origin;
}

- (CGFloat)scale
{
    if (_scale == 0) {
        _scale = DEFAULT_SCALE;
    }
    
    return _scale;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    // Draw the axis
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
}


@end
