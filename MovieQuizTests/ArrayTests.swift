//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Aleksey Shaposhnikov on 27.04.2023.
//

import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    func testGetValueInRang() throws {
        // Given
        let array = [1, 2, 3, 4, 5]

        // When
        let value = array[safe: 2]

        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }

    func testGetValueOutOfRang() throws {
        // Given
        let array = [1, 2, 3, 4, 5]

        // When
        let value = array[safe: 20]

        // Then
        XCTAssertNil(value)
    }
}
