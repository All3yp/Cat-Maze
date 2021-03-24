//
//  Extensions.swift
//  Cat Maze
//
//  Created by Matthijs on 19-06-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation

extension Dictionary {

    // Loads a JSON file from the app bundle into a new dictionary
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {

            let url = URL(fileURLWithPath: path)

            let data: Data? = try? Data(contentsOf: url)
            
            if let data = data {
                
                let dictionary: AnyObject? = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as AnyObject
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("Level file '\(filename)' is not valid JSON")
                    return nil
                }
            } else {
                print("Could not load level file: \(filename)")
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
