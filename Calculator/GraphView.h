//
//  GraphView.h
//  Calculator
//
//  Created by Tom Kraina on 16.08.2012.
//  Copyright (c) 2012 Tom Kraina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;
@protocol GraphViewDataSource <NSObject>
// Returns nil for invalid x-values
- (NSNumber *)graphView:(GraphView *)graphView yAxisValueForXAxisValue:(NSNumber *)xAxisValue;
@end

typedef enum {
    GraphViewModeDots = 1,
    GraphViewModeLine
} GraphViewMode;

@interface GraphView : UIView
@property(weak, nonatomic) id<GraphViewDataSource> datasource;
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGFloat scale;
@property(nonatomic) GraphViewMode mode;

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)pan:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)trippleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end
