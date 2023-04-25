import UIKit
import BetsCore

class OddCollectionViewListCell: UICollectionViewListCell {
    static let cellId = "OddCollectionViewListCell"

    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .horizontal

        return stackView
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)

        return label
    }()

    private var sellInLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)

        return label
    }()

    private var qualityLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with bet: Bet) {
        nameLabel.text = bet.name
        sellInLabel.text = "Sell In: \(bet.sellIn)"
        qualityLabel.text = "Quality: \(bet.quality)"
    }
}

extension OddCollectionViewListCell {
    private func setupViews() {
        contentView.addSubview(containerStackView)

        contentStackView.addArrangedSubview(sellInLabel)
        contentStackView.addArrangedSubview(qualityLabel)

        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(contentStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
}
