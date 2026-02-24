//
//  WebViewTests.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

//import XCTest
//@testable import ImageFeed
//
//@MainActor
//final class WebViewTests: XCTestCase {
//    
//    // MARK: - View-Presenter Connection Tests
//    
//    func testViewControllerCallsViewDidLoad() {
//        // given
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
//        let presenter = WebViewPresenterSpy()
//        viewController.presenter = presenter
//        presenter.view = viewController
//        
//        // when
//        _ = viewController.view // Триггерит вызов viewDidLoad()
//        
//        // then
//        XCTAssertTrue(presenter.viewDidLoadCalled, "Контроллер должен вызвать viewDidLoad у презентера")
//    }
//    
//    func testPresenterCallsLoadRequest() {
//        // given
//        let viewController = WebViewViewControllerSpy()
//        let authHelper = AuthHelper()
//        let presenter = WebViewPresenter(authHelper: authHelper)
//        viewController.presenter = presenter
//        presenter.view = viewController
//            
//        // when
//        presenter.viewDidLoad()
//            
//        // then
//        XCTAssertTrue(viewController.loadRequestCalled, "Презентер должен вызвать метод load(request:) во вью")
//    }
//    
//    // MARK: - Progress Logic Tests
//    
//    func testProgressVisibleWhenLessThenOne() {
//        // given
//        let authHelper = AuthHelper()
//        let presenter = WebViewPresenter(authHelper: authHelper)
//        let progress: Float = 0.6
//        
//        // when
//        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
//        
//        // then
//        XCTAssertFalse(shouldHideProgress, "Прогресс не должен быть скрыт, если он меньше 1.0")
//    }
//    
//    func testProgressHiddenWhenOne() {
//        // given
//        let authHelper = AuthHelper()
//        let presenter = WebViewPresenter(authHelper: authHelper)
//        let progress: Float = 1.0
//        
//        // when
//        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
//        
//        // then
//        XCTAssertTrue(shouldHideProgress, "Прогресс должен быть скрыт, когда он равен 1.0")
//    }
//    
//    // MARK: - AuthHelper Tests
//    
//    func testAuthHelperAuthURL() {
//        // given
//        let configuration = AuthConfiguration.standard
//        let authHelper = AuthHelper(configuration: configuration)
//        
//        // when
//        let url = authHelper.authURL()
//        guard let url = url else {
//            XCTFail("URL не должен быть nil")
//            return
//        }
//        let urlString = url.absoluteString
//        
//        // then
//        XCTAssertTrue(urlString.contains(configuration.authURLString))
//        XCTAssertTrue(urlString.contains(configuration.accessKey))
//        XCTAssertTrue(urlString.contains(configuration.redirectURI))
//        XCTAssertTrue(urlString.contains("code"))
//        XCTAssertTrue(urlString.contains(configuration.accessScope))
//    }
//    
//    func testCodeFromURL() {
//        // given
//        let authHelper = AuthHelper()
//        // Используем чистую строку URL для стабильности в тестовой среде Swift 6
//        let urlString = "https://unsplash.com/oauth/authorize/native?code=test_code"
//        guard let url = URL(string: urlString) else {
//            XCTFail("Не удалось создать тестовый URL")
//            return
//        }
//        
//        // when
//        let code = authHelper.code(from: url)
//        
//        // then
//        XCTAssertEqual(code, "test_code", "AuthHelper должен корректно извлекать код из URL")
//    }
//}
//
//// MARK: - Spy Objects
//
//final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
//    var presenter: WebViewPresenterProtocol?
//    var loadRequestCalled: Bool = false // Флаг для теста testPresenterCallsLoadRequest
//    
//    func load(request: URLRequest) {
//        loadRequestCalled = true
//    }
//    
//    func setProgressValue(_ newValue: Float) {}
//    func setProgressHidden(_ isHidden: Bool) {}
//}
//
//final class WebViewPresenterSpy: WebViewPresenterProtocol {
//    var viewDidLoadCalled: Bool = false
//    var view: WebViewViewControllerProtocol?
//    
//    func viewDidLoad() {
//        viewDidLoadCalled = true
//    }
//    
//    func didUpdateProgressValue(_ newValue: Double) {}
//    
//    func code(from url: URL) -> String? {
//        return nil
//    }
//}
