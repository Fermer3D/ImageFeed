//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        // 1. Сброс состояния
        if app.tabBars.firstMatch.waitForExistence(timeout: 5) {
            logout()
        }
        
        // 2. Кнопка входа
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        // 3. Ждем WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 15))

        // 4. Ввод логина (почты)
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 15))
        loginTextField.tap()
        loginTextField.typeText("danil.tretyachenko.03@yandex.ru")
        
        // 5. ПЕРЕХОД К ПАРОЛЮ
        loginTextField.typeText("\t")
        sleep(2)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        // Кликаем по паролю, чтобы вызвать клавиатуру именно для этого поля
        passwordTextField.tap()
        sleep(1)

        // --- СМЕНА ЯЗЫКА ПЕРЕД ПАРОЛЕМ ---
        // Пытаемся найти кнопку переключения языка (глобус)
        let nextKeyboardButton = app.keyboards.buttons["Next keyboard"]
        if nextKeyboardButton.exists {
            // Нажимаем, чтобы переключиться на английский
            nextKeyboardButton.tap()
            sleep(1)
        }

        // 6. Ввод пароля
        // Сначала заглавную букву отдельно, чтобы проверить смену раскладки
        passwordTextField.typeText("L")
        sleep(1)
        passwordTextField.typeText("ondon2003d")
        
        // Нажимаем Enter (ввод)
        passwordTextField.typeText("\n")
        
        // 7. Проверка перехода в ленту
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 20), "Авторизация не удалась. Возможно, язык не сменился.")
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
