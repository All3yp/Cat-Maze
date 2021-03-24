//
//  EventHandling.swift
//  Cat Maze
//
//  Created by Gabriel Hauber on 22/04/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import SpriteKit

// MARK: - cross-platform object type aliases

#if os(iOS)
typealias CCUIEvent = UITouch
typealias CCTapOrClickGestureRecognizer = UITapGestureRecognizer
#else
typealias CCUIEvent = NSEvent
typealias CCTapOrClickGestureRecognizer = NSClickGestureRecognizer
import Carbon // for the OS X virtual key codes!
#endif

enum Direction {
  case Up, Down, Left, Right
}
// ideally this would be a struct, but swiftc does not allow overriding functions declared in extensions
// unless the declaration is fully Objective-C compatible
/** abstracting events from keyboards, etc */
class ControllerEvent: NSObject {
  let direction: Direction
  init(direction: Direction) {
    self.direction = direction
  }
}

extension SKNode {

  #if os(iOS)

  // MARK: - iOS Touch handling

  open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    userInteractionBegan(event: touches.first!)
  }

  open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    userInteractionContinued(event: touches.first!)
  }

  open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    userInteractionEnded(event: touches.first!)
  }

  open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    userInteractionCancelled(event: touches.first!)
  }

  #else

  // MARK: - OS X mouse event handling

  override public func mouseDown(event: NSEvent) {
    userInteractionBegan(event)
  }

  override public func mouseDragged(event: NSEvent) {
    userInteractionContinued(event)
  }

  override public func mouseUp(event: NSEvent) {
    userInteractionEnded(event)
  }

  public override func keyDown(theEvent: NSEvent) {
    switch Int(theEvent.keyCode) {
    case kVK_UpArrow: controllerEvent(ControllerEvent(direction: .Up))
    case kVK_LeftArrow: controllerEvent(ControllerEvent(direction: .Left))
    case kVK_RightArrow: controllerEvent(ControllerEvent(direction: .Right))
    case kVK_DownArrow: controllerEvent(ControllerEvent(direction: .Down))
    default: break // nothing
    }
  }

  #endif

  // MARK: - Cross-platform event handling

  @objc func userInteractionBegan(event: CCUIEvent) {
  }
  
  @objc func userInteractionContinued(event: CCUIEvent) {
  }

  @objc func userInteractionEnded(event: CCUIEvent) {
  }

  @objc func userInteractionCancelled(event: CCUIEvent) {
  }

  @objc func controllerEvent(event: ControllerEvent) {
  }

}
