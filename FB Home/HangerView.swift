//
//  HangerView.swift
//  FB Home
//
//  Created by Mox Soini on 6.5.2015.
//  Copyright (c) 2015 Mox Soini. All rights reserved.
//

import UIKit

class HangerView : UIView {

  private lazy var sPt: CGPoint = { return CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2) }()
  private lazy var lineLength: CGFloat = { return self.bounds.size.height/2 }()
  private lazy var ePt: CGPoint = { return CGPoint(x: self.sPt.x, y: self.sPt.y + self.lineLength) }()

  var angle: CGFloat = 0 {
    didSet {
      ePt = CGPoint(x: sPt.x + lineLength * sin(angle), y: sPt.y + lineLength * cos(angle))
    }
  }

  override func didMoveToSuperview() {
    isOpaque = false
  }

  // Only override drawRect: if you perform custom drawing.
  override func draw(_ rect: CGRect) {

    super.draw(rect)

    // Drawing code

    guard let context = UIGraphicsGetCurrentContext() else { return }

    // black filled circle
    context.setFillColor(UIColor.black().cgColor)
    context.addEllipse(inRect: CGRect(x: sPt.x - lineLength, y: sPt.y - lineLength, width: lineLength*2, height: lineLength*2))
    context.fillPath()

    // white ticks
    context.setStrokeColor(UIColor.white().cgColor)
    context.setLineWidth(1.0)
    for i in 0..<8 {
      let angle = CGFloat(i) * 2 * CGFloat(M_PI) / 8
      let dx = lineLength * sin(angle)
      let dy = lineLength * cos(angle)
      context.moveTo(x: sPt.x + 5.0/6.0*dx, y: sPt.y + 5.0/6.0*dy) //start at this point
      context.addLineTo(x: sPt.x + dx, y: sPt.y + dy) //draw to this point
    }
    for i in 0..<24 {
      let angle = CGFloat(i) * 2 * CGFloat(M_PI) / 24;
      let dx = lineLength * sin(angle)
      let dy = lineLength * cos(angle)
      context.moveTo(x: sPt.x + 11.0/12.0*dx, y: sPt.y + 11.0/12.0*dy) //start at this point
      context.addLineTo(x: sPt.x + dx, y: sPt.y + dy) //draw to this point
    }
    context.strokePath()

    //red arrow
    context.setStrokeColor(UIColor.red().cgColor)
    context.setLineWidth(2.0)
    context.moveTo(x: sPt.x, y: sPt.y) //start at this point
    context.addLineTo(x: ePt.x, y: ePt.y) //draw to this point
    context.strokePath()

  }

}