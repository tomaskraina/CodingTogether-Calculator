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

- (CGPoint)pointInViewForPointInGraph:(CGPoint)point
{
    CGPoint pointInView = CGPointZero;
    pointInView.x = (point.x * self.scale) + self.origin.x;
    pointInView.y = self.origin.y - (point.y * self.scale);
    
    return pointInView;
}

- (CGPoint)pointInGraphForPointInView:(CGPoint)point
{
    CGPoint pointInGraph = CGPointZero;
    pointInGraph.x = (point.x - self.origin.x) / self.scale;
    pointInGraph.y = (self.origin.y - point.y) / self.scale;

    return pointInGraph;
}

- (void)drawGraphInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    NSInteger minX = [self pointInGraphForPointInView:CGPointZero].x;
    NSInteger maxX = [self pointInGraphForPointInView:CGPointMake(self.bounds.size.width, 0)].x;
    
    NSValue *previousYValue;
    for (CGFloat xValue = minX; xValue < maxX; xValue++) {
        NSNumber *yValue = [self.datasource graphView:self yAxisValueForXAxisValue:[NSNumber numberWithFloat:xValue]];
        CGPoint pointInView = [self pointInViewForPointInGraph:CGPointMake(xValue, [yValue doubleValue])];
        if (!previousYValue) {
            CGContextMoveToPoint(context, pointInView.x, pointInView.y);
        }
        else if (yValue) {
            CGContextAddLineToPoint(context, pointInView.x, pointInView.y);
        }
        
        previousYValue = yValue;
    }
    CGContextStrokePath(context);

    
    UIGraphicsPopContext();
}

- (void)drawRect:(CGRect)rect
{
    // Draw the axis
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // Draw the graph
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawGraphInContext:context];
}


@end
