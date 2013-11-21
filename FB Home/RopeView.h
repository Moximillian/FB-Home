//
//  RopeView.h
//  FB Home
//
//  Created by Mox Soini on 31.8.2013.
//  Copyright (c) 2013 Mox Soini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RopeView : UIView

- (void) setRope:(CGPoint)sPt to:(CGPoint)ePt;
- (void) initRopeLength:(CGPoint)sPt to:(CGPoint)ePt;

@end
