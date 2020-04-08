//
//  AnimalsViewController.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

final class AnimalsViewController: UIViewController {
    enum CellIdentifier: String {
        case animalCell = "AnimalCell"
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var viewModel = AnimalsViewModel()
    private lazy var dataSource = makeDataSource()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.shouldPresentLoginViewController {
            performSegue(withIdentifier: LoginViewController.identifier, sender: self)
        }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func getAnimalNames(_ sender: UIBarButtonItem) {
        viewModel.getAnimalNames { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.update()
            case .failure(let message):
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDiffableDataSource

extension AnimalsViewController {
    enum Section {
        case main
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Section, String> {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, name in
            let cell = tableView
                .dequeueReusableCell(withIdentifier: CellIdentifier.animalCell.rawValue,
                                     for: indexPath)
            
            cell.textLabel?.text = name
            return cell
        }
    }
    
    private func update() {
        activityIndicator.stopAnimating()
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
        snapshot.appendItems(viewModel.animalNames)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
