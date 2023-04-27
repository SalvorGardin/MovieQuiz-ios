//
//  TestFile.swift
//  MovieQuizUITests
//
//  Created by Aleksey Shaposhnikov on 27.04.2023.
//

import XCTest

class MovieQuizUITest: XCTestCase {
    func testGetValueInRang() throws {
        // Given
        let array = [1, 2, 3, 4, 5]

        // When
        let value = array[2]

        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
}
