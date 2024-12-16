import UIKit
import Foundation
import Combine
import SnapKit

class RecordsViewController: UIViewController {
    
    private var records: [Page] = []
    private var viewModel = RecordsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var selectedOption = "test"
    private let items = ["test", "anamnesis", "conclusion"]
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(RecordsCell.self, forCellReuseIdentifier: RecordsCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Tests", "Anamnesis", "Conclusion"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.systemGray6
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        fetchRecords()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchRecords()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedOption = items[sender.selectedSegmentIndex]
        fetchRecords()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalTo(view).inset(20)
            make.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                self.records = records?.page ?? []
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let errorMessage = errorMessage else { return }
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.loadingIndicator.isHidden = !isLoading
                isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
                self.tableView.isHidden = isLoading
            }
            .store(in: &cancellables)
    }
    
    private func fetchRecords() {
        viewModel.getRecords(recordType: selectedOption)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RecordsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordsCell.identifier, for: indexPath) as? RecordsCell else {
            return UITableViewCell()
        }
        cell.configure(with: records[indexPath.row])
        return cell
    }
}
