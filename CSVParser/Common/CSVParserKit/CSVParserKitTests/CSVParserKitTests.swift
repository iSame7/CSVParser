//
//  CSVParserKitTests.swift
//  CSVParserKitTests
//
//  Created by Sameh Mabrouk on 04/08/2021.
//

import XCTest
@testable import CSVParserKit

class CSVParserKitTests: XCTestCase {
    
    // MARK: - Test variables
    
    private var sut: CSV!
    
    // MARK: - Test life cycle
    
    override func setUp() {
        super.setUp()
        
        sut = try! CSV(string: "First name,Sur name,Issue count,Date of birth\nTheo,Jansen,5,1978-01-02T00:00:00\nFiona,de Vries,7,1950-11-12T00:00:00\nPetra,Boersma,1,2001-04-20T00:00:00")
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInit_createsHeader() {
        XCTAssertEqual(sut.header, ["First name", "Sur name", "Issue count", "Date of birth"])
    }
    
    func testInit_createsRows() {
        let expectedRows = [
            ["First name": "Theo", "Sur name": "Jansen", "Issue count": "5", "Date of birth": "1978-01-02T00:00:00"],
            ["First name": "Fiona", "Sur name": "de Vries", "Issue count": "7", "Date of birth": "1950-11-12T00:00:00"],
            ["First name": "Petra", "Sur name": "Boersma", "Issue count": "1", "Date of birth": "2001-04-20T00:00:00"]
        ]
        for(index, row) in sut.rows.enumerated() {
            XCTAssertEqual(expectedRows[index], row)
        }
    }
    
    func testInit_createsColumns() {
        let expected = [
            "First name": ["Theo", "Fiona", "Petra"],
            "Sur name": ["Jansen", "de Vries", "Boersma"],
            "Issue count": ["5", "7", "1"],
            "Date of birth": ["1978-01-02T00:00:00", "1950-11-12T00:00:00", "2001-04-20T00:00:00"]
        ]
        XCTAssertEqual(Set(sut.columns.keys), Set(expected.keys))
        for (key, value) in sut.columns {
            XCTAssertEqual(expected[key] ?? [], value)
        }
    }
    
    func testInit_WhenThereAreIncompleteRows_createsRows() {
        sut = try! CSV(string: "First name,Sur name,Issue count,Date of birth\nTheo,Jansen,5,1978-01-02T00:00:00\nFiona,de Vries,7,1950-11-12T00:00:00\nPetra,Boersma,1")

        let expectedRows = [
            ["First name": "Theo", "Sur name": "Jansen", "Issue count": "5", "Date of birth": "1978-01-02T00:00:00"],
            ["First name": "Fiona", "Sur name": "de Vries", "Issue count": "7", "Date of birth": "1950-11-12T00:00:00"],
            ["First name": "Petra", "Sur name": "Boersma", "Issue count": "1", "Date of birth": ""]
        ]
        for(index, row) in sut.rows.enumerated() {
            XCTAssertEqual(expectedRows[index], row)
        }
    }
    
    func testInit_IgnoreExtraCarriageReturn() {
        sut = try! CSV(string: "First name,Sur name,Issue count,Date of birth\nTheo,Jansen,5,1978-01-02T00:00:00\nFiona,de Vries,7,1950-11-12T00:00:00\nPetra,Boersma,1\r\n")

        let expectedRows = [
            ["First name": "Theo", "Sur name": "Jansen", "Issue count": "5", "Date of birth": "1978-01-02T00:00:00"],
            ["First name": "Fiona", "Sur name": "de Vries", "Issue count": "7", "Date of birth": "1950-11-12T00:00:00"],
            ["First name": "Petra", "Sur name": "Boersma", "Issue count": "1", "Date of birth": ""]
        ]
        for(index, row) in sut.rows.enumerated() {
            XCTAssertEqual(expectedRows[index], row)
        }
    }
    
    func testCSV_WhenContainsQuotes_createsHeader() {
        sut = try! CSV(string: "First name,\"Sur name, person\",Issue count\n\"Theo\",\"Jansen, John\",22\nFiona,de Vries,\"10\"")
        XCTAssertEqual(sut.header, ["First name", "Sur name, person", "Issue count"])
    }
    
    func testCSV_WhenContainsQuotes_creatsContent() {
        sut = try! CSV(string: "First name,\"Sur name, person\",Issue count\n\"Theo\",\"Jansen, John\",22\nFiona,de Vries,\"10\"")

        let rows = sut.rows
        XCTAssertEqual(rows[0], [
                        "First name": "Theo",
                        "Sur name, person": "Jansen, John",
                        "Issue count": "22",
        ])
        
        XCTAssertEqual(rows[1], [
                        "First name": "Fiona",
                        "Sur name, person": "de Vries",
                        "Issue count": "10",
        ])
    }
    
    func testInit_CreatesRows_fromURL() {
        let url = url(forResource: "issues", withExtension: "csv")!
        sut = try! CSV(url: url)
        
        let expectedRows = [
            ["First name": "Theo", "Sur name": "Jansen", "Issue count": "5", "Date of birth": "1978-01-02T00:00:00"],
            ["First name": "Fiona", "Sur name": "de Vries", "Issue count": "7", "Date of birth": "1950-11-12T00:00:00"],
            ["First name": "Petra", "Sur name": "Boersma", "Issue count": "1", "Date of birth": "2001-04-20T00:00:00"]
        ]
        for (index, row) in sut.rows.enumerated() {
            XCTAssertEqual(expectedRows[index], row)
        }
    }
    
    func testInit_CreatesRows_fromFileName() {
        sut = try! CSV(name: "issues", extension: "csv", bundle: Bundle(for: CSVParserKitTests.self))
        
        let expectedRows = [
            ["First name": "Theo", "Sur name": "Jansen", "Issue count": "5", "Date of birth": "1978-01-02T00:00:00"],
            ["First name": "Fiona", "Sur name": "de Vries", "Issue count": "7", "Date of birth": "1950-11-12T00:00:00"],
            ["First name": "Petra", "Sur name": "Boersma", "Issue count": "1", "Date of birth": "2001-04-20T00:00:00"]
        ]
        for (index, row) in sut.rows.enumerated() {
            XCTAssertEqual(expectedRows[index], row)
        }
    }
    
    func testParserPerformance() {
        let url = url(forResource: "large", withExtension: "csv")!
        sut = try! CSV(url: url)
        
        measure {
            _ = self.sut.rows
        }
    }
}

private extension CSVParserKitTests {
    func url(forResource name: String, withExtension type: String) -> URL? {
        let bundle = Bundle(for: CSVParserKitTests.self)
        
        guard let url = bundle.url(forResource: name, withExtension: type)  else {
            return nil
        }
        
        return url
    }
}
