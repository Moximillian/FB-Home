//
//  RopeView.swift
//  FB Home
//
//  Created by Mox Soini on 6.5.2015.
//  Copyright (c) 2015 Mox Soini. All rights reserved.
//

import UIKit

class RopeView : UIView {

  private var sPt = CGPoint(x: 0, y: 0)
  private var ePt = CGPoint(x: 0, y: 0)
  private var initialLength: CGFloat = 1.0
  private var length: CGFloat = 1.0

  override func didMoveToSuperview() {
    isOpaque = false
  }

  func initRope(from sPt: CGPoint, to ePt: CGPoint) {
    initialLength = hypot(ePt.x - sPt.x, ePt.y - sPt.y)
  }

  func setRope(sPt:CGPoint, to ePt:CGPoint) {
    self.sPt = sPt
    self.ePt = ePt
    length = hypot(ePt.x - sPt.x, ePt.y - sPt.y)
  }

  // Only override drawRect: if you perform custom drawing.
  override func draw(_ rect: CGRect) {

    super.draw(rect)

    // Drawing code

    guard let context = UIGraphicsGetCurrentContext() else { return }

    // rope
    context.setStrokeColor(UIColor.black().cgColor)

    let w = max(min(pow(initialLength / length, 2.0), 1.0), 0.1)
    context.setAlpha(0.7*w)
    //NSLog(@"Rope alpha: %.2f <-- %.2f %.2f", w, _initialLength, _length);

    context.setLineWidth(w * 5.0)
    context.moveTo(x: sPt.x, y: sPt.y) //start at this point
    context.addLineTo(x: ePt.x, y: ePt.y) //draw to this point
    context.strokePath()
  }

}
