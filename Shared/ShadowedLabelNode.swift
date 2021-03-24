//
//  ShadowedLabelNode.swift
//  Cat Maze
//
//  Created by Gabriel Hauber on 22/04/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation

import SpriteKit

class ShadowedLabelNode: SKNode {

  // 1
  private let label: SKLabelNode
  private let shadowLabel: SKLabelNode

  // 2
  var text: String {
    get {
        return label.text!
    }
    set {
      label.text = newValue
      shadowLabel.text = newValue
    }
  }

  // 3
  var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
    get {
      return label.verticalAlignmentMode
    }
    set {
      label.verticalAlignmentMode = newValue
      shadowLabel.verticalAlignmentMode = newValue
    }
  }

  var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {
    get {
      return label.horizontalAlignmentMode
    }
    set {
      label.horizontalAlignmentMode = newValue
      shadowLabel.horizontalAlignmentMode = newValue
    }
  }

  var size: CGSize {
    return calculateAccumulatedFrame().size
  }
  
  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  // 4
  init(fontNamed fontName: String, fontSize size: CGFloat, color: SKColor, shadowColor: SKColor) {
    label = SKLabelNode(fontNamed: fontName)
    label.fontSize = size
    label.fontColor = color

    shadowLabel = SKLabelNode(fontNamed: fontName)
    shadowLabel.fontSize = size
    shadowLabel.fontColor = shadowColor

    super.init()

    shadowLabel.position = CGPoint(x: 1, y: -1)
    addChild(shadowLabel)
    addChild(label)
  }
}
