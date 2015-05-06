//
//  RopeView.m
//  FB Home
//
//  Created by Mox Soini on 31.8.2013.
//  Copyright (c) 2013 Mox Soini. All rights reserved.
//

#import "RopeView.h"

@interface RopeView ()

@property (nonatomic) CGPoint sPt;
@property (nonatomic) CGPoint ePt;
@property (nonatomic) CGFloat initialLength;
@property (nonatomic) CGFloat length;

@end

@implementation RopeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _sPt = CGPointMake(0, 0);
        _ePt = _sPt;
        _initialLength = 1.0;
        _length = 1.0;
        [self setOpaque:NO];
    }
    return self;
}

- (void) initRopeLength:(CGPoint)sPt to:(CGPoint)ePt
{
    _initialLength = sqrtf(powf(ePt.x - sPt.x, 2.0) + powf(ePt.y - sPt.y, 2.0));
}



- (void) setRope:(CGPoint)sPt to:(CGPoint)ePt
{
    _sPt = sPt;
    _ePt = ePt;
    _length = sqrtf(powf(ePt.x - sPt.x, 2.0) + powf(ePt.y - sPt.y, 2.0));
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // rope
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);

    CGFloat w = powf(_initialLength / _length, 2.0);
    if (w > 1.0) w = 1.0;
    CGContextSetAlpha(context, 0.7*w);
    //NSLog(@"Rope alpha: %.2f <-- %.2f %.2f", w, _initialLength, _length);

    CGContextSetLineWidth(context, w * 5.0);
    CGContextMoveToPoint(context, _sPt.x, _sPt.y); //start at this point
    CGContextAddLineToPoint(context, _ePt.x, _ePt.y); //draw to this point
    CGContextStrokePath(context);
    
}


@end
