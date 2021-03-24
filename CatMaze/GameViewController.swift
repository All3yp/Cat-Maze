//
//  GameViewController.swift
//  CatMaze
//
//  Created by Gabriel Hauber on 28/04/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import SpriteKit

// alias the type to make it easier to use cross-platform
typealias CCView = SKView

// minimal logic here - just enough to bootstrap the game before handing
// over to the platform-agnostic shared code
class GameViewController: UIViewController {

    var gameController: GameController!

    // Set up the game controller
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = view as! CCView
        skView.isMultipleTouchEnabled = false

        gameController = GameController(skView: skView)
    }

    // The game begins once the view has appeared
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameController.beginGame()
    }


    // MARK: - device setup
    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.allButUpsideDown.rawValue)
        } else {
            return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.all.rawValue)
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

}
