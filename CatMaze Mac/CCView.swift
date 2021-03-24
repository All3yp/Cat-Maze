//
//  CCView.swift
//  CookieCrunch
//
//  Created by Gabriel Hauber on 22/04/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import SpriteKit

@objc(CCView)
class CCView: SKView {

  var userInteractionEnabled: Bool = true

  override func hitTest(aPoint: NSPoint) -> NSView? {
    if userInteractionEnabled {
      return super.hitTest(aPoint)
    }
    return nil
  }
}
