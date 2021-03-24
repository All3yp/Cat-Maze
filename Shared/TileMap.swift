//
//  TileMap.swift
//  CatMaze
//
//  Created by Gabriel on 28-04-15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import Foundation
import SpriteKit

/** a tile has a name and texture (based on the tile's name) */
class Tile: SKSpriteNode {
  init(name: String) {
    let texture = SKTexture(imageNamed: name)
    super.init(texture: texture, color: .clear, size: texture.size())
    self.name = name
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }
}


/** represents a coordinate in the tile map */
struct TileCoord {
  var col: Int
  var row: Int

  /** coordinate 1 cell above self */
  var top: TileCoord {
    return TileCoord(col: col, row: row - 1)
  }
  /** coordinate 1 cell to the left of self */
  var left: TileCoord {
    return TileCoord(col: col - 1, row: row)
  }
  /** coordinate 1 cell to the right of self */
  var right: TileCoord {
    return TileCoord(col: col + 1, row: row)
  }
  /** coordinate 1 cell beneath self */
  var bottom: TileCoord {
    return TileCoord(col: col, row: row + 1)
  }
  /** coordinate top-left of self */
  var topLeft: TileCoord {
    return TileCoord(col: col - 1, row: row - 1)
  }
  /** coordinate top-right of self */
  var topRight: TileCoord {
    return TileCoord(col: col + 1, row: row - 1)
  }
  /** coordinate bottom-left of self */
  var bottomLeft: TileCoord {
    return TileCoord(col: col - 1, row: row + 1)
  }
  /** coordinate bottom-right of self */
  var bottomRight: TileCoord {
    return TileCoord(col: col + 1, row: row + 1)
  }
}

extension TileCoord: CustomStringConvertible {
  var description: String {
    return "[col=\(col) row=\(row)]"
  }
}

extension TileCoord: Equatable {}
func ==(lhs: TileCoord, rhs: TileCoord) -> Bool {
  return lhs.col == rhs.col && lhs.row == rhs.row
}

// Allow expressions such as let diff = coord1 - coord2
func -(lhs: TileCoord, rhs: TileCoord) -> TileCoord {
  return TileCoord(col: lhs.col - rhs.col, row: lhs.row - rhs.row)
}


/**
 A tilemap is a SpriteKit node. It contains one or more LayerNodes as children.
 The configuration for a tilemap is read in from a JSON file.
 */
class TileMapNode: SKNode {

  // width and height (in tiles) for a level
  private var columns = 0
  private var rows = 0

  private var tileSize = CGSize.zero

  var playerSpawnTileCoord = TileCoord(col: 0, row: 0)

  var size: CGSize {
    return CGSize(width: CGFloat(columns) * tileSize.width, height: CGFloat(rows) * tileSize.height)
  }

  // each level can have one or more layers consisting of a 2D array of tiles
  private var layers = [String : LayerNode]()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }

  /** Create a level by loading it from a JSON file. Returns nil if there is a problem loading the file. */
  init?(filename: String) {
    super.init()

    if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) {

      var tileTypes = [Int : String]()

      // the tile definitions that make up a level
      if let tilesArray = dictionary["tileNames"] as? [String] {
        for (index, tileName) in tilesArray.enumerated() {
          tileTypes[index + 1] = tileName
        }
      }

      // width and height in tiles for the level
      columns = dictionary["width"] as? Int ?? 0
      rows = dictionary["height"] as? Int ?? 0

      tileSize.width = dictionary["tileWidth"] as? CGFloat ?? 0
      tileSize.height = dictionary["tileHeight"] as? CGFloat ?? 0

      playerSpawnTileCoord.col = dictionary["playerSpawnX"] as? Int ?? 0
      playerSpawnTileCoord.row = dictionary["playerSpawnY"] as? Int ?? 0

      if let layersArray = dictionary["layers"] as? Array<Dictionary<String, AnyObject>> {
        for (layerIndex, layerSpec) in layersArray.enumerated() {
          let layerName = layerSpec["name"] as? String ?? "Layer_\(layerIndex)"
          if let tilesArray = layerSpec["tiles"] as? [[Int]] {
            let layerNode = LayerNode(name: layerName, tileData: tilesArray, columns: columns, rows: rows, tileNames: tileTypes, tileSize: tileSize)
            addChild(layerNode)
            layers[layerName] = layerNode
          }
        }
      }
    } else {
      return nil
    }
  }

  func isValidTileCoord(tileCoord: TileCoord) -> Bool {
    return ((0..<columns).contains(tileCoord.col) && (0..<rows).contains(tileCoord.row))
  }

  // Converts a position relative to the tile map into a tile coordinate column, row pair
  func tileCoordForPosition(position: CGPoint) -> TileCoord {
    return TileCoord(col: Int(position.x / tileSize.width), row: Int((size.height - position.y) / tileSize.height))
  }

  // Converts a column, row pair into a CGPoint that is relative to the tileMap
  func positionForTileCoord(tileCoord: TileCoord) -> CGPoint {
    return CGPoint(x: CGFloat(tileCoord.col) * tileSize.width + tileSize.width / 2,
                   y: size.height - (CGFloat(tileCoord.row) * tileSize.width + tileSize.width / 2))
  }

  func layerNamed(name: String, hasObjectNamed objectName: String, atCoord tileCoord: TileCoord) -> Bool {
    if let layer = layers[name] {
      return layer.hasObjectNamed(objectName: objectName, atCoord: tileCoord)
    }
    return false
  }

  func layerNamed(name: String, removeObjectAtCoord tileCoord: TileCoord) {
    if let layer = layers[name] {
      layer.removeObjectAtCoord(tileCoord: tileCoord)
    }
  }

}


/** A single layer within a TileMap node */
class LayerNode: SKNode {

  private let rows: Int
  private let columns: Int

  private let tileSize: CGSize

  private var tiles: Array2D<Tile>

  var size: CGSize {
    return CGSize(width: CGFloat(columns) * tileSize.width, height: CGFloat(rows) * tileSize.height)
  }

  init(name: String, tileData: [[Int]], columns: Int, rows: Int, tileNames: [Int : String], tileSize: CGSize) {

    self.rows = rows
    self.columns = columns
    self.tileSize = tileSize

    self.tiles = Array2D<Tile>(columns: columns, rows: rows)

    super.init()

    self.name = name

    // Loop through the rows
    for (row, rowData) in tileData.enumerated() {

      // Note: In Sprite Kit (0, 0) is a the bottom of the screen,
      // so we need to read this file upside down.
      let tileRow = rows - row - 1

      // Loop through the columns in the current row
      for (column, value) in rowData.enumerated() {
        if let tileName = tileNames[value] {
          let tile = Tile(name: tileName)
          tile.anchorPoint = CGPoint.zero
          tile.position = CGPoint(x: tileSize.width * CGFloat(column), y: tileSize.height * CGFloat(tileRow))
          addChild(tile)
          tiles[column, row] = tile
        }
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) is not used in this app")
  }

  func hasObjectNamed(objectName: String, atCoord tileCoord: TileCoord) -> Bool {
    if let tile = tiles[tileCoord.col, tileCoord.row], tile.name == objectName {
      return true
    }
    return false
  }

  func removeObjectAtCoord(tileCoord: TileCoord) {
    if let object = tiles[tileCoord.col, tileCoord.row] {
      object.removeFromParent()
      tiles[tileCoord.col, tileCoord.row] = nil
    }
  }
  
}


