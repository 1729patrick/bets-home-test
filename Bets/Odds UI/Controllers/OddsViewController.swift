import UIKit

class OddsViewController: UIViewController {
    private(set) var list: UICollectionView!
    private(set) var activity: UIActivityIndicatorView!

    private var viewModel: OddsViewModel!

    init(viewModel: OddsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        configureNavbar()
        configureCollectionView()
        configureActivityIndicator()

        updateOdds()
    }

    @objc func updateOdds() {
        Task {
            do {
                await showLoadingIndicator(true)
                try await viewModel.updateOdds()
                await showLoadingIndicator(false)
            } catch {
                showAlert(
                    title: "Couldn't fetch the items.",
                    message: "Please try again later."
                )

                await showLoadingIndicator(false)
            }
        }
    }
}

extension OddsViewController {
    func setupView() {
        navigationItem.title = "Odds"
        view.backgroundColor = .systemBackground
    }
}

extension OddsViewController {
    private func configureNavbar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "arrow.clockwise"),
                style: .done,
                target: self,
                action: #selector(updateOdds)
            ),
        ]
    }
}

extension OddsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.odds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.odds[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OddCollectionViewListCell.cellId, for: indexPath)

        guard let cell = cell as? OddCollectionViewListCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: item)

        return cell
    }
}

extension OddsViewController {
    private func configureCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        list = UICollectionView(frame: view.frame, collectionViewLayout: layout)

        list.register(OddCollectionViewListCell.self, forCellWithReuseIdentifier: OddCollectionViewListCell.cellId)

        list.dataSource = self
        list.translatesAutoresizingMaskIntoConstraints = false
        list.isHidden = true

        view.addSubview(list)

        NSLayoutConstraint.activate([
            list.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            list.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            list.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension OddsViewController {
    private func configureActivityIndicator() {
        activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activity)

        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension OddsViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Try Again",
                style: .default,
                handler: { _ in self.updateOdds() }
            )
        )

        present(alert, animated: true, completion: nil)
    }
}

extension OddsViewController {
    func showLoadingIndicator(_ isLoading: Bool) async {
        await MainActor.run {
            if isLoading {
                self.activity.startAnimating()
            } else {
                self.activity.stopAnimating()
            }

            self.list.isHidden = isLoading

            list.reloadData()
        }
    }
}
