import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Public Properties
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Инициализация презентера, если он не был внедрен (например, через SceneDelegate)
        if presenter == nil {
            let presenter = ImagesListPresenter()
            self.presenter = presenter
            presenter.view = self
        }
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - ImagesListViewControllerProtocol
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Добавляем отступы сверху и снизу для всей таблицы
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photos = presenter?.photos,
                photos.indices.contains(indexPath.row)
            else { return }
            
            let photo = photos[indexPath.row]
            if let url = URL(string: photo.largeImageURL) {
                viewController.imageURL = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photos = presenter?.photos, photos.indices.contains(indexPath.row) else { return }
        let photo = photos[indexPath.row]
        
        cell.delegate = self
        
        // Настройка состояния лайка
        cell.setIsLiked(photo.isLiked)
        
        // Настройка даты
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        // Загрузка изображения через Kingfisher
        let placeholder = UIImage(named: "Stub")
        cell.cellImage.kf.indicatorType = .activity
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.2))]
            )
        } else {
            cell.cellImage.image = placeholder
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Сообщаем презентеру, что нужно подгрузить следующую страницу
        presenter?.willDisplayRow(at: indexPath)
    }

    // Тот самый метод, который исправляет размеры фотографий
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photos = presenter?.photos,
              photos.indices.contains(indexPath.row) else {
            return 0
        }
        
        let photo = photos[indexPath.row]
        
        // imageInsets должны совпадать с теми, что заданы в констрейнтах ячейки в Storyboard
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        
        guard imageWidth > 0 else { return 0 }
        
        // Вычисляем коэффициент масштабирования под ширину экрана
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
