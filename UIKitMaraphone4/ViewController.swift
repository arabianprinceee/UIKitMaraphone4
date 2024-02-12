import UIKit

class Item: Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.value == rhs.value && lhs.isSelected == rhs.isSelected
    }
    
    var value: Int
    var isSelected: Bool
    
    init(value: Int, isSelected: Bool) {
        self.value = value
        self.isSelected = isSelected
    }
}

final class Cell: UITableViewCell {

    static let identifier = "Cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(
        _ isSelected: Bool
    ) {
        accessoryType = isSelected ? .checkmark : .none
    }
    
}

final class ViewController: UIViewController {
    
    var items: [Item] = {
        return Array(0...30).map { Item(value: $0, isSelected: false) }
    }()
    
    lazy var shuffleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shuffle", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(.init(handler: { [self] _ in
            var shuffledItems = items.shuffled()
            var moves = [(from: IndexPath, to: IndexPath)]()
            for (newIndex, element) in shuffledItems.enumerated() {
                if let oldIndex = items.firstIndex(of: element) {
                    moves.append((
                        from: IndexPath(row: oldIndex, section: 0),
                        to: IndexPath(row: newIndex, section: 0)
                    ))
                }
            }
            tableView.performBatchUpdates({
                for move in moves {
                    tableView.moveRow(at: move.from, to: move.to)
                }
            }, completion: nil)
        }), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
        table.allowsMultipleSelection = true
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(shuffleButton)
        
        NSLayoutConstraint.activate([
            shuffleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            shuffleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? Cell
        else { return }
        
        var item = items[indexPath.row]
        item.isSelected.toggle()
        cell.setSelected(item.isSelected)
        tableView.deselectRow(at: indexPath, animated: true)
        
        if item.isSelected {
            items.remove(at: indexPath.row)
            items.insert(item, at: 0)
            tableView.beginUpdates()
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: indexPath.section))
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 48 }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as? Cell else { fatalError() }
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.value)"
        cell.setSelected(item.isSelected)
        return cell
    }
    
}
