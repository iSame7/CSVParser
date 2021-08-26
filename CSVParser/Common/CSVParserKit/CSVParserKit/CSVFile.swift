//
//  CSVFile.swift
//  CSVParserKit
//
//  Created by Sameh Mabrouk on 04/08/2021.
//

public struct CSVFile: CSVViewable {
    
    public var rows: [[String: String]]
    public var columns: [String: [String]]
    private var parser: CSVParsing
    
    init(parser: CSVParsing, header: [String], text: String, delimiter: Character) throws {
        self.parser = parser
        var rows = [[String: String]]()
        var columns = [String: [String]]()
        
        try self.parser.getAllRowsAsDict(text: text, header: header, delimiter: delimiter, completionHandler: { dict in
            rows.append(dict)
        })
        
        for field in header {
            columns[field] = rows.map { $0[field] ?? "" }
        }
                
        self.rows = rows
        self.columns = columns
    }
}
