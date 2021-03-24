//
//  AppDelegate.swift
//  CatMaze Mac
//
//  Created by Gabriel Hauber on 28/04/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var skView: CCView!

  var gameController: GameController!

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    gameController = GameController(skView: skView)
    gameController.beginGame()
  }

  func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
    return true
  }
}
