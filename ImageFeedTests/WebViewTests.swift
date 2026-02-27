import XCTest
@testable import ImageFeed

@MainActor
final class WebViewTests: XCTestCase {
    // Выносим презентер и его зависимости на уровень свойств
    private var presenter: WebViewPresenter!
    private var viewController: WebViewViewControllerSpy!
    private var authHelper: AuthHelper!

    override func setUp() {
        super.setUp()
        
        // Создаем изоляцию для каждого теста
        let config = AuthConfiguration.standard
        authHelper = AuthHelper(configuration: config)
        viewController = WebViewViewControllerSpy()
        presenter = WebViewPresenter(authHelper: authHelper)
        
        // Устанавливаем связи
        presenter.view = viewController
        viewController.presenter = presenter
    }

    override func tearDown() {
        presenter = nil
        viewController = nil
        authHelper = nil
        super.tearDown()
    }

    func testPresenterCallsLoadRequest() {
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let progress: Float = 1.0
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test_code")]
        let url = urlComponents.url!
        
        // when
        let code = authHelper.code(from: url)
        
        // then
        XCTAssertEqual(code, "test_code")
    }
}

// В самом низу файла WebViewTests.swift

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}
