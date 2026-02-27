//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    @MainActor
    func testProfileVCCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    func viewDidLoad() { viewDidLoadCalled = true }
    func didTapLogout() {}
    func didConfirmLogout() {}
}
