//
//  CSV.swift
//  CSVParserKit
//
//  Created by Sameh Mabrouk on 04/08/2021.
//

final public class CSV {
    
    static public let comma: Character = ","

    private var text: String
    private var delimiter: Character
    public let header: [String]
    private var parser: CSVParsing
    lazy var csvFile: CSVFile = {
        self.parser = CSVParser(delimiter: self.delimiter)
        return try! CSVFile(parser: self.parser, header: self.header, text: self.text, delimiter: self.delimiter)
    }()
    
    public var rows: [[String : String]] {
        return csvFile.rows
    }

    public var columns: [String : [String]] {
        return csvFile.columns
    }
    
    public init(string: String, delimiter: Character = comma) throws {
        self.text = string
        self.delimiter = delimiter
        self.parser = CSVParser(delimiter: delimiter)
        self.header = try self.parser.getAllRows(text: self.text).first ?? []
    }
    
    public convenience init?(name: String, extension ext: String? = nil, bundle: Bundle = .main, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            return nil
        }
        try self.init(url: url, delimiter: delimiter, encoding: encoding, loadColumns: loadColumns)
    }

    public convenience init(url: URL, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        
        try self.init(string: contents, delimiter: delimiter)
    }
}
