//
//  ToolTip.swift
//  Catalogr
//
//  Created by jfeigel on 6/24/20.
//  Copyright © 2020 jfeigel. All rights reserved.
//

import UIKit

enum ToolTipPosition: Int {
  case left, center, right
}

class ToolTip: UIView {
  
  static var activeToolTips: [UIView: ToolTip] = [:]
  
  var roundRect: CGRect!
  var forItem: UIView!
  var inView: UIView!
  var tipPosition: ToolTipPosition!
  var tipOffset: CGFloat!
  
  let tipWidth: CGFloat = 20.0
  let tipHeight: CGFloat = 12.0
  
  convenience init(forItem: UIView, inView: UIView, maxWidth width: CGFloat, maxHeight height: CGFloat, text: String, tipPos: ToolTipPosition = .center) {
    var textSize = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize)], context: nil).size
    textSize.width = ceil(textSize.width) + 30
    textSize.height = ceil(textSize.height) + 30

    self.init(frame: CGRect(
      x: forItem.center.x - (textSize.width - forItem.frame.size.width),
      y: forItem.frame.minY - textSize.height,
      width: textSize.width,
      height: textSize.height
    ))
    
    self.forItem = forItem
    self.inView = inView
    self.tipPosition = tipPos
    self.tipOffset = forItem.frame.size.width / 2
    print(forItem.frame.size.width / 2)
    
    createLabel(text)
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    drawToolTip(rect)
  }
  
  func show() {
    guard ToolTip.activeToolTips[forItem] == nil else { return }
    
    ToolTip.activeToolTips[forItem] = self
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
    inView.addSubview(self)
    
    self.transform = CGAffineTransform(scaleX: 0, y: 0)
    UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: { self.transform = .identity })
  }
  
  @objc func handleTap(_ sender: UIGestureRecognizer) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      options: [.curveEaseInOut],
      animations: { self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) },
      completion: { _ in
        self.removeFromSuperview()
        self.transform = .identity
        ToolTip.activeToolTips[self.forItem] = nil
      }
    )
  }
  
  private func getX() -> CGFloat {
    switch tipPosition {
    case .left:
      return roundRect.minX + tipOffset
    case .center:
      return roundRect.midX - (tipWidth / 2)
    case .right:
      return roundRect.maxX - tipOffset - tipWidth
    case .none:
      return 0.0
    }
  }

  private func createTipPath() -> UIBezierPath {
    let toolTipRectX = getX()
    let toolTipRect = CGRect(x: toolTipRectX, y: roundRect.maxY, width: tipWidth, height: tipHeight)
    
    let trianglePath = UIBezierPath()
    trianglePath.move(to: CGPoint(x: toolTipRect.minX, y: toolTipRect.minY))
    trianglePath.addLine(to: CGPoint(x: toolTipRect.maxX, y: toolTipRect.minY))
    trianglePath.addLine(to: CGPoint(x: toolTipRect.midX, y: toolTipRect.maxY))
    trianglePath.addLine(to: CGPoint(x: toolTipRect.minX, y: toolTipRect.minY))
    trianglePath.close()
    
    return trianglePath
  }
  
  private func createShapeLayer(_ path: CGPath) -> CAShapeLayer {
    let shape = CAShapeLayer()
    
    shape.path = path
    shape.fillColor = UIColor(named: "tertiaryBackground")?.cgColor
    shape.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
    shape.shadowOffset = CGSize(width: 0, height: 2)
    shape.shadowRadius = 5.0
    shape.shadowOpacity = 0.8
    
    return shape
  }
  
  private func createLabel(_ text: String) {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - tipHeight))
    
    label.text = text
    label.textColor = .white
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    
    addSubview(label)
  }
  
  private func drawToolTip(_ rect: CGRect) {
    roundRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tipHeight)
    
    let roundRectPath = UIBezierPath(roundedRect: roundRect, cornerRadius: 5.0)
    let trianglePath = createTipPath()
    
    roundRectPath.append(trianglePath)
    
    let shape = createShapeLayer(roundRectPath.cgPath)
    
    self.layer.insertSublayer(shape, at: 0)
  }
  
}
