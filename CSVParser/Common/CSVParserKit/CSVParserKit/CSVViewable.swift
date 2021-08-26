//
//  CSVViewable.swift
//  CSVParserKit
//
//  Created by Sameh Mabrouk on 04/08/2021.
//

public protocol CSVViewable {
    associatedtype Rows
    associatedtype Columns
    
    var rows: Rows { get }
    var columns: Columns { get }
}
