//
//  Array2D.swift
//  Cat Maze
//
//  Created by Matthijs on 19-06-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

struct Array2D<T> {
    let columns: Int
    let rows: Int
    private var array: Array<T?>

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows*columns)
    }

    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
}
