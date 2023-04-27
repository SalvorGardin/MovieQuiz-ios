//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleksey Shaposhnikov on 27.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["YesButton"].tap()

        sleep(3)
        let indexLabel = app.staticTexts["Index"].label
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertEqual(indexLabel, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["NoButton"].tap()

        sleep(3)
        let indexLabel = app.staticTexts["Index"].label
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertEqual(indexLabel, "2/10")
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testResultAlert() throws {
        sleep(2)

        for _ in 1...10 {
            app.buttons["YesButton"].tap()
            sleep(2)
        }

        let alert = app.alerts["resultAlert"]

        sleep(2)

        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
}
