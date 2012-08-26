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
@synthesize mode = _mode;

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

- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    
    [self setNeedsDisplay];
}

- (CGFloat)scale
{
    if (_scale == 0) {
        _scale = DEFAULT_SCALE;
    }
    
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    [self setNeedsDisplay];
}

- (void)setMode:(GraphViewMode)mode
{
    _mode = mode;
    
    [self setNeedsDisplay];
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

- (void)drawGraphByLinesInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    
    CGContextBeginPath(context);
    NSInteger minViewX = 0;
    NSInteger maxViewX = self.bounds.size.width * self.contentScaleFactor;
    
    NSValue *previousYValue;
    for (CGFloat viewX = minViewX; viewX < maxViewX; viewX++) {
        CGFloat xValue = [self pointInGraphForPointInView:CGPointMake(viewX / self.contentScaleFactor, 0)].x;
        NSNumber *yValue = [self.datasource graphView:self yAxisValueForXAxisValue:[NSNumber numberWithDouble:xValue]];
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

- (void)drawGraphByDotsInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    
    NSInteger minViewX = 0;
    NSInteger maxViewX = self.bounds.size.width * self.contentScaleFactor;
    
    for (CGFloat viewX = minViewX; viewX < maxViewX; viewX++) {
        CGFloat xValue = [self pointInGraphForPointInView:CGPointMake(viewX / self.contentScaleFactor, 0)].x;
        NSNumber *yValue = [self.datasource graphView:self yAxisValueForXAxisValue:[NSNumber numberWithDouble:xValue]];
        CGPoint pointInView = [self pointInViewForPointInGraph:CGPointMake(xValue, [yValue doubleValue])];
        if (yValue) {
            CGContextFillRect(context, CGRectMake(pointInView.x, pointInView.y, 1 / self.contentScaleFactor, 1 / self.contentScaleFactor));
        }
        
        UIGraphicsPopContext();
    }
}


- (void)drawRect:(CGRect)rect
{
    // Draw the axis
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // Draw the graph
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.mode) {
        case GraphViewModeDots:
            [self drawGraphByDotsInContext:context];
            break;
            
        default:
            [self drawGraphByLinesInContext:context];
            break;
    }
}

#pragma mark - UIGestureRecognizer

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer
{    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.scale *= gestureRecognizer.scale;
        gestureRecognizer.scale = 1;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gestureRecognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)trippleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.origin = [gestureRecognizer locationInView:self];
    }
}

@end
