//
//  GameScene.swift
//  Cat Maze
//
//  Created by Matthijs on 19-06-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene {

  let levelName: String
  let tileMap: TileMapNode
  let cat = Cat()

  // pre-load some sound effects
  let loseSound = SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)
  let winSound = SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)

  // on-screen status labels
  let bonesLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 22, color: SKColor.white.withAlphaComponent(0.9), shadowColor: SKColor.black.withAlphaComponent(0.9))

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }

  init(size: CGSize, levelName: String) {
    self.levelName = levelName
    tileMap = TileMapNode(filename: levelName)!
    super.init(size: size)
    addChild(tileMap)
    cat.gameScene = self

    updateBoneCount(numBones: cat.numBones)
    bonesLabel.position = CGPoint(x: 20 + bonesLabel.size.width / 2, y: 20)
    addChild(bonesLabel)
  }

  func setViewportCenter(position: CGPoint) {
    var x = max(position.x, size.width / 2)
    var y = max(position.y, size.height / 2)
    x = min(x, tileMap.size.width - size.width / 2)
    y = min(y, tileMap.size.height - size.height / 2)
    let actualPosition = CGPoint(x: x, y: y)
    let centerOfView = CGPoint(x: size.width / 2, y: size.height / 2)
    let viewPoint = centerOfView - actualPosition
    tileMap.position = viewPoint
  }

  func spawnCat() {
    let spawnCoord = tileMap.playerSpawnTileCoord
    let spawnPos = tileMap.positionForTileCoord(tileCoord: spawnCoord)
    setViewportCenter(position: spawnPos)

    cat.position = spawnPos
    tileMap.addChild(cat)
  }

  override func controllerEvent(event: ControllerEvent) {
    super.controllerEvent(event: event)
    cat.moveInDirection(direction: event.direction)
  }

  override func userInteractionBegan(event: CCUIEvent) {
    cat.moveToward(target: event.location(in: tileMap))
  }

  override func update(_ currentTime: TimeInterval) {
    setViewportCenter(position: cat.position)
  }

  func isWalkableTileForTileCoord(tileCoord: TileCoord) -> Bool {
    return tileMap.isValidTileCoord(tileCoord: tileCoord) && !isWallAtTileCoord(coord: tileCoord)
  }

  func isWallAtTileCoord(coord: TileCoord) -> Bool {
    return tileMap.layerNamed(name: "Background", hasObjectNamed: "Wall", atCoord: coord)
  }

  func isBoneAtTileCoord(coord: TileCoord) -> Bool {
    return tileMap.layerNamed(name: "Objects", hasObjectNamed: "Bone", atCoord: coord)
  }

  func isDogAtTileCoord(coord: TileCoord) -> Bool {
    return tileMap.layerNamed(name: "Objects", hasObjectNamed: "DogDown1", atCoord: coord)
  }

  func isExitAtTileCoord(coord: TileCoord) -> Bool {
    return tileMap.layerNamed(name: "Objects", hasObjectNamed: "Exit", atCoord: coord)
  }

  func removeObjectAtTileCoord(coord: TileCoord) {
    tileMap.layerNamed(name: "Objects", removeObjectAtCoord: coord)
  }

  func updateBoneCount(numBones: Int) {
    bonesLabel.text = "Bones: \(numBones)"
  }

  func loseGame() {
    run(loseSound)
    endScene(won: false)
  }

  func winGame() {
    run(winSound)
    endScene(won: true)
  }

  private func endScene(won: Bool) {
    cat.run(SKAction.sequence([
      SKAction.scale(by: 3, duration: 0.5),
      SKAction.wait(forDuration: 1.0),
      SKAction.scale(to: 0, duration: 0.5)
    ]),
    completion: { [weak self] in
      self?.showRestartMenu(won: won)
    })
    cat.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 0.5)))
  }

  private func showRestartMenu(won: Bool) {
    let messageLabel = ShadowedLabelNode(fontNamed: "GillSans-Bold", fontSize: 48, color: SKColor.white, shadowColor: SKColor.black)
    messageLabel.text = won ? "You win!" : "You lose!"
    messageLabel.setScale(0.1)
    messageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
    addChild(messageLabel)

    let restartButton = ButtonNode(text: "Restart", fontNamed: "GillSans-Bold", fontSize: 32, textColor: SKColor.white)
    restartButton.action = { [weak self] (button) in
      self?.restartGame()
    }
    restartButton.setScale(0.1)
    restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
    addChild(restartButton)

    messageLabel.run(SKAction.scale(to: 1.0, duration: 0.5))
    restartButton.run(SKAction.scale(to: 1.0, duration: 0.5))
  }

  private func restartGame() {
    // reload the current scene
    let scene = GameScene(size: size, levelName: levelName)
    scene.spawnCat()
    view?.presentScene(scene, transition: SKTransition.flipVertical(withDuration: 0.5))
  }
}
