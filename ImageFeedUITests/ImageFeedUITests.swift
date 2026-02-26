import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    private func typeSlowly(_ text: String, into element: XCUIElement) {
            for character in text {
                element.typeText(String(character))
                usleep(150_000) // задержка на 0.15 секунды
            }
        }
    
    func testAuth() throws {
            app.launchArguments = ["ResetDataForTests"]
            app.launch()
            
            app.buttons["Authenticate"].tap()
            
            let webView = app.webViews["UnsplashWebView"]
            
            XCTAssertTrue(webView.waitForExistence(timeout: 10))

            let loginTextField = webView.descendants(matching: .textField).element
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
            loginTextField.tap()
            loginTextField.typeText("danil.tretyachenko.03@yandex.ru")
         
            app.toolbars.buttons["Done"].tap()
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
            passwordTextField.tap()
            typeSlowly("London2003d", into: passwordTextField)
            
            //app.toolbars.buttons["Done"].tap()
            
            let loginButton = webView.buttons["Login"]
            if loginButton.waitForExistence(timeout: 10) {
                loginButton.tap()
            }
            
            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
            XCTAssertTrue(cell.waitForExistence(timeout: 7))
        }
    
    // Вспомогательные методы
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.swipeUp()
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        cellToLike.buttons["LikeButtonOff"].tap()
        XCTAssertTrue(cellToLike.buttons["LikeButtonOn"].waitForExistence(timeout: 5))
        cellToLike.buttons["LikeButtonOn"].tap()
        XCTAssertTrue(cellToLike.buttons["LikeButtonOff"].waitForExistence(timeout: 5))
        cellToLike.tap()
        app.buttons["nav back button white"].tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["Danil Tretyachenko"].exists)
        XCTAssertTrue(app.staticTexts["@danil_tretyachenko"].exists)
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].buttons["Да"].tap()
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }
    
    private func logout() {
        app.tabBars.buttons.element(boundBy: 1).tap()
        let logoutButton = app.buttons["logout button"]
        if logoutButton.waitForExistence(timeout: 5) {
            logoutButton.tap()
            app.alerts["Пока, пока!"].buttons["Да"].tap()
        }
    }
}
