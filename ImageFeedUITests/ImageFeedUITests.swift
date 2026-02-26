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
        
        // 1. Ждем, пока таблица появится на экране
        XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
        
        // 2. Свайпаем таблицу вверх (требование ревью)
        tablesQuery.element.swipeUp()
        
        // 3. Вместо поиска ячейки по индексу, ищем ЛЮБУЮ видимую кнопку LikeButtonOff
        // Это гарантирует, что мы не попадем на ячейку с INFINITY координатами
        let likeButton = tablesQuery.buttons["LikeButtonOff"].firstMatch
        
        // Ждем, пока кнопка реально появится в поле видимости
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        // 4. Кликаем по кнопке. Если обычный tap() падает, используем этот хак:
        if likeButton.isHittable {
            likeButton.tap()
        } else {
            // Если кнопка видна, но Xcode вредничает, принудительно кликаем в её центр
            likeButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        
        // 5. Проверяем, что лайк стал On
        let likeButtonOn = tablesQuery.buttons["LikeButtonOn"].firstMatch
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5))
        
        // Отменяем лайк
        likeButtonOn.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        // 6. Открываем ячейку, в которой нажали лайк
        // Чтобы не запутаться, просто тапаем по любой ячейке на экране
        tablesQuery.cells.element(boundBy: 1).tap()
        
        // 7. Работа с SingleImageView (зум и возврат)
        let image = app.scrollViews.images.element(at: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        // Требование ревью: зум
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
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
