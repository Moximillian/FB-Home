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

/*
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    NSLog(@"Hello!...");
    return self;
}*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.sPt = CGPointMake(0, 0);
        self.ePt = self.sPt;
        self.initialLength = 1.0;
        self.length = 1.0;
        [self setOpaque:NO];
    }
    return self;
}

- (void) initRopeLength:(CGPoint)sPt to:(CGPoint)ePt
{
    self.initialLength = sqrtf(powf(ePt.x - sPt.x, 2.0) + powf(ePt.y - sPt.y, 2.0));
}



- (void) setRope:(CGPoint)sPt to:(CGPoint)ePt
{
    self.sPt = sPt;
    self.ePt = ePt;
    self.length = sqrtf(powf(ePt.x - sPt.x, 2.0) + powf(ePt.y - sPt.y, 2.0));
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

    CGFloat w = powf(self.initialLength / self.length, 2.0);
    if (w > 1.0) w = 1.0;
    CGContextSetAlpha(context, 0.7*w);
    NSLog(@"Rope alpha: %.2f <-- %.2f %.2f", w, self.initialLength, self.length);

    CGContextSetLineWidth(context, w * 5.0);
    CGContextMoveToPoint(context, self.sPt.x, self.sPt.y); //start at this point
    CGContextAddLineToPoint(context, self.ePt.x, self.ePt.y); //draw to this point
    CGContextStrokePath(context);
    
}


@end
