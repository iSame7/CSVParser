//
//  CSVParser.swift
//  CSVParserKit
//
//  Created by Sameh Mabrouk on 05/08/2021.
//

import Foundation

protocol CSVParsing {
    func getAllRows(text: String) throws -> [[String]]
    func getAllRowsAsDict(text: String, header: [String], delimiter: Character, completionHandler: @escaping ([String : String]) -> ()) throws
}
    
class CSVParser: CSVParsing {
    
    enum CSVParseError: Error {
        case generic(message: String)
        case missingQuotation(message: String)
    }
    
    private var atStart = true
    private var parsingField = false
    private var parsingQuotes = false
    private var innerQuotes = false
    private let delimiter: Character

    init(delimiter: Character) {
        self.delimiter = delimiter
    }
    
    func getAllRows(text: String) throws -> [[String]] {
        var rows = [[String]]()
        
        try getARow(text: text, completionHandler: { row in
            rows.append(row)
        })
        return rows
    }
    
    
    func getAllRowsAsDict(text: String, header: [String], delimiter: Character, completionHandler: @escaping ([String : String]) -> ()) throws {
        try getARow(text: text, startAt: 1) { fields in
            var dict = [String: String]()
            for (index, head) in header.enumerated() {
                dict[head] = index < fields.count ? fields[index] : ""
            }
            completionHandler(dict)
        }
    }
}

// MARK: - Helpers

private extension CSVParser {
    
    func getARow(text: String, startAt: Int = 0, completionHandler: @escaping ([String]) -> ()) throws {
        var currentIndex = text.startIndex
        let endIndex = text.endIndex

        var fields = [String]()
        var field = ""

        var count = 0

        while currentIndex < endIndex {
            let char = text[currentIndex]

            try processCharacter(char, isProcessingFieldFinished: {
                fields.append(field)
                field = ""
            }, isProcessingRowFinished: {
                fields.append(field)
                if count >= startAt {
                    completionHandler(fields)
                }
                
                count += 1
                fields = [String]()
                field = ""
            }, foundCharacter: { char in
                field.append(char)
            })

            currentIndex = text.index(after: currentIndex)
        }

        if !fields.isEmpty || !field.isEmpty {
            fields.append(field)
            completionHandler(fields)
        }
    }
    
    func processCharacter(_ char: Character, isProcessingFieldFinished: () -> Void, isProcessingRowFinished: () -> Void, foundCharacter: (Character) -> Void) throws {
        if atStart {
            if char == "\"" {
                atStart = false
                parsingQuotes = true
            } else if char == delimiter {
                isProcessingFieldFinished()
            } else if char.isNewline {
                isProcessingRowFinished()
            } else {
                parsingField = true
                atStart = false
                foundCharacter(char)
            }
        } else if parsingField {
            if innerQuotes {
                if char == "\"" {
                    foundCharacter(char)
                    innerQuotes = false
                } else {
                    throw CSVParseError.missingQuotation(message: "Can't have non-quote here: \(char)")
                }
            } else {
                if char == "\"" {
                    innerQuotes = true
                } else if char == delimiter {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    isProcessingFieldFinished()
                } else if char.isNewline {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    isProcessingRowFinished()
                } else {
                    foundCharacter(char)
                }
            }
        } else if parsingQuotes {
            if innerQuotes {
                if char == "\"" {
                    foundCharacter(char)
                    innerQuotes = false
                } else if char == delimiter {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    isProcessingFieldFinished()
                } else if char.isNewline {
                    atStart = true
                    parsingQuotes = false
                    innerQuotes = false
                    isProcessingRowFinished()
                } else {
                    throw CSVParseError.missingQuotation(message: "Can't have non-quote here: \(char)")
                }
            } else {
                if char == "\"" {
                    innerQuotes = true
                } else {
                    foundCharacter(char)
                }
            }
        } else {
            throw CSVParseError.generic(message: "me_irl")
        }
    }
}
