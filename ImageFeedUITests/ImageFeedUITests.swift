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
    // ВАЖНО: Для успешного прохождения UI-тестов необходимо, чтобы в симуляторе была установлена только английская раскладка (Settings -> General -> Keyboard -> Keyboards -> Оставить только English). Если будет включена русская, ввод пароля в WebView может пройти некорректно.
    func testAuth() throws {
        if !app.buttons["Authenticate"].exists {
                // Переходим в профиль
                let profileTab = app.tabBars.buttons.element(boundBy: 1)
                if profileTab.waitForExistence(timeout: 5) {
                    profileTab.tap()
                    
                    // Нажимаем выход
                    let logoutButton = app.buttons["profileLogoutButton"]
                    if logoutButton.waitForExistence(timeout: 5) {
                        logoutButton.tap()
                        
                        // Подтверждаем выход в алерте
                        let alert = app.alerts["Пока, пока!"]
                        if alert.waitForExistence(timeout: 5) {
                            alert.buttons["Да"].tap()
                        }
                    }
                }
            }
            
            // 2. Теперь мы точно на экране авторизации, продолжаем обычный тест
            app.launchArguments = ["ResetDataForTests"]
            app.launch()
            
            let authButton = app.buttons["Authenticate"]
            XCTAssertTrue(authButton.waitForExistence(timeout: 5))
            authButton.tap()
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

        // Вместо смены языка (которая невозможна), мы гарантируем, что поле пустое
        // и пробуем ввести текст.
        typeSlowly("London2003d", into: passwordTextField)
        
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
        
        // 1. Ждем появления таблицы, а не первой ячейки
        func testFeed() throws {
            let tablesQuery = app.tables
            
            // 1. Ждем появления таблицы
            XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
            
            // 2. Свайпаем саму ТАБЛИЦУ вверх (требование ревью)
            tablesQuery.element.swipeUp()
            
            // 3. Используем firstMatch, чтобы найти ПЕРВУЮ ВИДИМУЮ кнопку лайка.
            // Это избавляет от проблем с ячейками, у которых пустой фрейм.
            let likeButton = tablesQuery.buttons["LikeButtonOff"].firstMatch
            
            // Ждем, пока кнопка реально появится
            XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
            
            // 4. Если обычный тап не срабатывает, используем этот безопасный метод.
            // Мы проверяем, что координаты НЕ бесконечны перед нажатием.
            let coordinate = likeButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            
            // ВАЖНО: Делаем еще один свайп, если кнопка всё еще "в бесконечности"
            if likeButton.frame.origin.y.isInfinite {
                app.swipeUp()
            }
            
            coordinate.tap()
            
            // 5. Проверяем включение лайка (LikeButtonOn)
            let likeButtonOn = tablesQuery.buttons["LikeButtonOn"].firstMatch
            XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5))
            
            // Отменяем лайк
            likeButtonOn.tap()
            XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
            
            // 6. Переход в полноэкранный режим
            // Тапаем по первой ячейке, которую видим
            tablesQuery.cells.element(boundBy: 1).tap()
            
            // 7. Зум и возврат (требование ревью)
            let image = app.scrollViews.images.element(boundBy: 0)
            XCTAssertTrue(image.waitForExistence(timeout: 5))
            
            image.pinch(withScale: 3, velocity: 1)
            image.pinch(withScale: 0.5, velocity: -1)
            
            app.buttons["nav back button white"].tap()
        }
    }
        // MARK: - Тестируем сценарий профиля
        func testProfile() throws {
            // Переходим в профиль (вторая вкладка таббара)
            let profileTab = app.tabBars.buttons.element(boundBy: 1)
            XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
            profileTab.tap()
            
            // Проверяем наличие персональных данных (IDs из ProfileViewController)
            XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            let logoutButton = app.buttons["logout button"]
            XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
            logoutButton.tap()
            
            // Проверяем алерт
            let alert = app.alerts["Пока, пока!"]
            XCTAssertTrue(alert.waitForExistence(timeout: 5))
            
            let yesButton = alert.buttons["Да"]
            XCTAssertTrue(yesButton.exists)
            yesButton.tap()
            
            // Проверяем, что вернулись на экран авторизации
            let authButton = app.buttons["Authenticate"]
            XCTAssertTrue(authButton.waitForExistence(timeout: 10))
        }
    }

