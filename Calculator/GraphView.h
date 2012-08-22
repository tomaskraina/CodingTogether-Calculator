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
- (NSInteger *)graphView:(GraphView *)graphView yAxisValueForXAxisValue:(NSInteger *)xAxisValue;
@end

@interface GraphView : UIView
@property(weak, nonatomic) id<GraphViewDataSource> datasource;
@property(nonatomic) CGPoint origin;
@property(nonatomic) CGFloat scale;
@end
