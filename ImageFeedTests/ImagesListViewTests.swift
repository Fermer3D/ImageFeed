//
//  ImagesListViewTests.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import XCTest
import UIKit
@testable import ImageFeed

@MainActor
final class ImagesListViewTests: XCTestCase {

    // MARK: - Тесты

    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        viewController.setValue(UITableView(), forKey: "tableView")

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testWillDisplayCallsPresenterWillDisplayRow() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        let tableView = UITableView()
        viewController.setValue(tableView, forKey: "tableView")
        _ = viewController.view

        let indexPath = IndexPath(row: 3, section: 0)

        // when
        viewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: indexPath)

        // then
        XCTAssertEqual(presenter.willDisplayRowCalledWith, indexPath)
    }

    func testDidTapLikeCallsPresenterDidTapLike() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        let tableView = TableViewIndexPathSpy()
        tableView.stubIndexPath = IndexPath(row: 0, section: 0)
        viewController.setValue(tableView, forKey: "tableView")
        _ = viewController.view

        let cell = ImagesListCell()

        // when
        viewController.imageListCellDidTapLike(cell)

        // then
        XCTAssertEqual(presenter.didTapLikeCalledWith, IndexPath(row: 0, section: 0))
    }

    func testUpdateTableViewAnimatedInsertsRows() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        let tableView = TableViewInsertRowsSpy()
        tableView.dataSource = nil // Критично для Spy
        
        viewController.setValue(tableView, forKey: "tableView")
        _ = viewController.view

        // when
        // Передаем значения, которые контроллер должен обработать
        viewController.updateTableViewAnimated(oldCount: 2, newCount: 5)

        // then
        let expectedIndexPaths = [
            IndexPath(row: 2, section: 0),
            IndexPath(row: 3, section: 0),
            IndexPath(row: 4, section: 0)
        ]
        XCTAssertEqual(tableView.insertRowsCalledWith, expectedIndexPaths)
    }
}

// MARK: - Spies

@MainActor
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = [] // Хранилище для тестов
    
    var viewDidLoadCalled = false
    var willDisplayRowCalledWith: IndexPath?
    var didTapLikeCalledWith: IndexPath?

    func viewDidLoad() { viewDidLoadCalled = true }
    func willDisplayRow(at indexPath: IndexPath) { willDisplayRowCalledWith = indexPath }
    func didTapLike(at indexPath: IndexPath) { didTapLikeCalledWith = indexPath }
}

@MainActor
final class TableViewIndexPathSpy: UITableView {
    var stubIndexPath: IndexPath?
    override func indexPath(for cell: UITableViewCell) -> IndexPath? {
        return stubIndexPath
    }
}

@MainActor
final class TableViewInsertRowsSpy: UITableView {
    var insertRowsCalledWith: [IndexPath] = []

    // Полная блокировка системной логики анимирования
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalledWith = indexPaths
    }

    // Заглушки параметров, чтобы избежать внутренних проверок UIKit
    override var numberOfSections: Int { 1 }
    override func numberOfRows(inSection section: Int) -> Int { 0 }
}
