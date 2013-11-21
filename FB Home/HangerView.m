//
//  HangerView.m
//  FB Home
//
//  Created by Mox Soini on 31.8.2013.
//  Copyright (c) 2013 Mox Soini. All rights reserved.
//

#import "HangerView.h"

@interface HangerView ()

@property (nonatomic) CGPoint sPt;
@property (nonatomic) CGPoint ePt;
@property (nonatomic) CGFloat lineLength;

@end

@implementation HangerView

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
        self.sPt = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.lineLength = self.bounds.size.height/2;
        self.ePt = CGPointMake(self.sPt.x, self.sPt.y + self.lineLength);
        [self setOpaque:NO];
    }
    return self;
}


- (void) setAngle:(double)angle
{
    self.ePt = CGPointMake(self.sPt.x + self.lineLength * sin(angle),
                           self.sPt.y + self.lineLength * cos(angle));
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // Drawing code    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // black filled circle
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(self.sPt.x - self.lineLength, self.sPt.y - self.lineLength, self.lineLength*2, self.lineLength*2));
    CGContextFillPath(context);

    // white ticks
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    for (int i = 0; i < 8; i++) {
        CGFloat angle = i * 2 * M_PI / 8;
        CGFloat dx = self.lineLength * sin(angle);
        CGFloat dy = self.lineLength * cos(angle);
        CGContextMoveToPoint(context, self.sPt.x + 5.0/6.0*dx, self.sPt.y + 5.0/6.0*dy); //start at this point
        CGContextAddLineToPoint(context, self.sPt.x + dx, self.sPt.y + dy); //draw to this point
    }
    for (int i = 0; i < 24; i++) {
        CGFloat angle = i * 2 * M_PI / 24;
        CGFloat dx = self.lineLength * sin(angle);
        CGFloat dy = self.lineLength * cos(angle);
        CGContextMoveToPoint(context, self.sPt.x + 11.0/12.0*dx, self.sPt.y + 11.0/12.0*dy); //start at this point
        CGContextAddLineToPoint(context, self.sPt.x + dx, self.sPt.y + dy); //draw to this point
    }
    CGContextStrokePath(context);
    
    //red arrow
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, self.sPt.x, self.sPt.y); //start at this point
    CGContextAddLineToPoint(context, self.ePt.x, self.ePt.y); //draw to this point
    CGContextStrokePath(context);
    
}


@end
