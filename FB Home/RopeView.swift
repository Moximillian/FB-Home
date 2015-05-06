//
//  RopeView.swift
//  FB Home
//
//  Created by Mox Soini on 6.5.2015.
//  Copyright (c) 2015 Mox Soini. All rights reserved.
//

import UIKit

class RopeView : UIView {

    private var sPt = CGPointMake(0, 0)
    private var ePt = CGPointMake(0, 0)
    private var initialLength: CGFloat = 1.0
    private var length: CGFloat = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        // Initialization code
        opaque = false
    }

    func initRopeLength(sPt: CGPoint, to ePt: CGPoint) {
        initialLength = sqrt(pow(ePt.x - sPt.x, 2.0)) + pow(ePt.y - sPt.y, 2.0)
    }


    func setRope(sPt:CGPoint, to ePt:CGPoint) {
        self.sPt = sPt
        self.ePt = ePt
        length = sqrt(pow(ePt.x - sPt.x, 2.0) + pow(ePt.y - sPt.y, 2.0))
    }

    // Only override drawRect: if you perform custom drawing.
    override func drawRect(rect: CGRect) {

        super.drawRect(rect)

        // Drawing code

        let context = UIGraphicsGetCurrentContext()

        // rope
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)

        let w = max(min(pow(initialLength / length, 2.0), 1.0), 0.1)
        CGContextSetAlpha(context, 0.7*w)
        //NSLog(@"Rope alpha: %.2f <-- %.2f %.2f", w, _initialLength, _length);

        CGContextSetLineWidth(context, w * 5.0)
        CGContextMoveToPoint(context, sPt.x, sPt.y) //start at this point
        CGContextAddLineToPoint(context, ePt.x, ePt.y) //draw to this point
        CGContextStrokePath(context)
    }
    
}
