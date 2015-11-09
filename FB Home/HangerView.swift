//
//  HangerView.swift
//  FB Home
//
//  Created by Mox Soini on 6.5.2015.
//  Copyright (c) 2015 Mox Soini. All rights reserved.
//

import UIKit

class HangerView : UIView {

    private lazy var sPt: CGPoint = { return CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) }()
    private lazy var lineLength: CGFloat = { return self.bounds.size.height/2 }()
    private lazy var ePt: CGPoint = { return CGPointMake(self.sPt.x, self.sPt.y + self.lineLength) }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        // Initialization code
        opaque = false
    }


    func setAngle(angle: CGFloat) {
        ePt = CGPointMake(sPt.x + lineLength * sin(angle), sPt.y + lineLength * cos(angle))
    }

    // Only override drawRect: if you perform custom drawing.
    override func drawRect(rect: CGRect) {

        super.drawRect(rect)

        // Drawing code

        let context = UIGraphicsGetCurrentContext()

        // black filled circle
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextAddEllipseInRect(context, CGRectMake(sPt.x - lineLength, sPt.y - lineLength, lineLength*2, lineLength*2))
        CGContextFillPath(context)

        // white ticks
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, 1.0)
        for i in 0..<8 {
            let angle = CGFloat(i) * 2 * CGFloat(M_PI) / 8
            let dx = lineLength * sin(angle)
            let dy = lineLength * cos(angle)
            CGContextMoveToPoint(context, sPt.x + 5.0/6.0*dx, sPt.y + 5.0/6.0*dy) //start at this point
            CGContextAddLineToPoint(context, sPt.x + dx, sPt.y + dy) //draw to this point
        }
        for i in 0..<24 {
            let angle = CGFloat(i) * 2 * CGFloat(M_PI) / 24;
            let dx = lineLength * sin(angle)
            let dy = lineLength * cos(angle)
            CGContextMoveToPoint(context, sPt.x + 11.0/12.0*dx, sPt.y + 11.0/12.0*dy) //start at this point
            CGContextAddLineToPoint(context, sPt.x + dx, sPt.y + dy) //draw to this point
        }
        CGContextStrokePath(context)

        //red arrow
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        CGContextMoveToPoint(context, sPt.x, sPt.y) //start at this point
        CGContextAddLineToPoint(context, ePt.x, ePt.y) //draw to this point
        CGContextStrokePath(context)
        
    }

}