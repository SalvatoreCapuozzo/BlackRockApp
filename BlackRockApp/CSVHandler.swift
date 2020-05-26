//
//  CSVHandler.swift
//  BlackRockApp
//
//  Created by Salvatore Capuozzo on 26/05/2020.
//  Copyright © 2020 Salvatore Capuozzo. All rights reserved.
//

import Foundation

class CSVHandler {
    class func readDataFromCSV(fileName:String, fileType: String)-> String!{
            guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
                else {
                    return nil
            }
            do {
                var contents = try String(contentsOfFile: filepath, encoding: .utf8)
                contents = cleanRows(file: contents)
                return contents
            } catch {
                print("File Read Error for file \(filepath)")
                return nil
            }
        }


    class func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }

    class func csv(data: String) -> [[String]] {
       var result: [[String]] = []
       let rows = data.components(separatedBy: "\n")
       for row in rows {
           let columns = row.components(separatedBy: ",")
           result.append(columns)
       }
       return result
   }
}

