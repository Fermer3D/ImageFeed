//
//  ImagesListViewTests.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {

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

        let cell = ImagesListCell(style: .default, reuseIdentifier: ImagesListCell.reuseIdentifier)

        // when
        viewController.imageListCellDidTapLike(cell)

        // then
        XCTAssertEqual(presenter.didTapLikeCalledWith, IndexPath(row: 0, section: 0))
    }

    func testUpdateTableViewAnimatedInsertsRows() {
        // given
        let viewController = ImagesListViewController()
        let tableView = TableViewInsertRowsSpy()
        viewController.setValue(tableView, forKey: "tableView")
        _ = viewController.view

        // when
        viewController.updateTableViewAnimated(oldCount: 2, newCount: 5)

        // then
        XCTAssertEqual(tableView.insertRowsCalledWith, [
            IndexPath(row: 2, section: 0),
            IndexPath(row: 3, section: 0),
            IndexPath(row: 4, section: 0)
        ])
    }

    func testReloadRowReloadsThatRow() {
        // given
        let viewController = ImagesListViewController()
        let tableView = TableViewReloadRowsSpy()
        viewController.setValue(tableView, forKey: "tableView")
        _ = viewController.view

        let indexPath = IndexPath(row: 7, section: 0)

        // when
        viewController.reloadRow(at: indexPath)

        // then
        XCTAssertEqual(tableView.reloadRowsCalledWith, [indexPath])
    }

    func testPrepareForSeguePassesLargeImageURL() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        presenter.photos = [
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "https://example.com/thumb.jpg",
                largeImageURL: "https://example.com/large.jpg",
                isLiked: false
            )
        ]
        viewController.presenter = presenter
        presenter.view = viewController

        viewController.setValue(UITableView(), forKey: "tableView")
        _ = viewController.view

        let destination = SingleImageViewController()
        let segue = UIStoryboardSegue(
            identifier: "ShowSingleImage",
            source: viewController,
            destination: destination
        )

        // when
        viewController.prepare(for: segue, sender: IndexPath(row: 0, section: 0))

        // then
        XCTAssertEqual(destination.imageURL?.absoluteString, "https://example.com/large.jpg")
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    var photos: [Photo] = []

    var viewDidLoadCalled = false
    var willDisplayRowCalledWith: IndexPath?
    var didTapLikeCalledWith: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayRow(at indexPath: IndexPath) {
        willDisplayRowCalledWith = indexPath
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalledWith = indexPath
    }
}

final class TableViewIndexPathSpy: UITableView {
    var stubIndexPath: IndexPath?
    override func indexPath(for cell: UITableViewCell) -> IndexPath? {
        stubIndexPath
    }
}

final class TableViewInsertRowsSpy: UITableView {
    var insertRowsCalledWith: [IndexPath] = []

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalledWith = indexPaths
    }
}

final class TableViewReloadRowsSpy: UITableView {
    var reloadRowsCalledWith: [IndexPath] = []

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadRowsCalledWith = indexPaths
    }
}
