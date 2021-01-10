//
//  ViewController.swift
//  velocity_demo
//
//  Created by Jerry Walton on 1/5/21.
//

import UIKit

public let zipcodeMinLength = 4

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    enum ViewMode {
        case search, results
    }
    
    private var viewMode = ViewMode.search
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(handleSearchKeysUpdatedNotif), name: .SearchKeysUpdatedNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWeatherResultsUpdatedNotif), name: .WeatherResultsUpdatedNotif, object: nil)

        handleViewModeChange()
        segmentControl.selectedSegmentIndex = 0
        searchBar.becomeFirstResponder()
    }

    @IBAction func handleViewModeChange() {
        print("handleViewModeChange")
        var hide = false
        var editing = true
        if segmentControl.selectedSegmentIndex == 0 {
            viewMode = .search
        } else {
            viewMode = .results
            hide = true
            editing = false
        }
        self.searchBar.isHidden = hide
        self.tableView.isEditing = editing
        self.tableView.reloadData()
    }
    
    @IBAction func handleRefreshBtn() {
        print("handleRefreshBtn")
        tableView.reloadData()
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView numberOfRowsInSection")
        var nRows = 0
        switch viewMode {
        case .search:
            nRows = AppModel.sharedInstance.searchKeys.count
        default:
            nRows = AppModel.sharedInstance.weatherResults.count
        }
        return nRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell: UITableViewCell
        switch viewMode {
        case .search:
            guard let scell = (tableView.dequeueReusableCell(withIdentifier: SearchCell.identifier) as? SearchCell) else {
                return UITableViewCell()
            }
            scell.label.text = "\(AppModel.sharedInstance.searchKeys[indexPath.row])"
            cell = scell
            break
        case .results:
            guard let rcell = (tableView.dequeueReusableCell(withIdentifier: ResultsCell.identifier) as? ResultsCell) else {
                return UITableViewCell()
            }
            let weatherResult = AppModel.sharedInstance.weatherResults[indexPath.row]
            let zipCode = AppModel.sharedInstance.searchKeys[indexPath.row]
            
            var weatherStr = "Unkown weather"
                if let weatherDescription = weatherResult.weather?[0].description {
                    weatherStr = weatherDescription
                } else {
                    if let weatherMain = weatherResult.weather?[0].main {
                        weatherStr = weatherMain
                    }
                }
            rcell.label.text = "\(zipCode) - \(weatherStr)"
            cell = rcell
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AppModel.sharedInstance.searchKeys.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension ViewController {
    @objc public func handleSearchKeysUpdatedNotif() {
        print("handleSearchKeysUpdatedNotif")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @objc public func handleWeatherResultsUpdatedNotif() {
        print("handleWeatherResultsUpdatedNotif")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.tableView.reloadData()
        })
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        guard let searchStr = searchBar.text, searchStr.count >= zipcodeMinLength else { return }
        AppModel.sharedInstance.addSearchKey(searchKey: searchStr)
        searchBar.text = ""
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        AppModel.sharedInstance.clearSearchKeys()
        AppModel.sharedInstance.clearWeatherResults()
        tableView.reloadData()
    }
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarResultsListButtonClicked")
        DispatchQueue.main.async {
            self.segmentControl.selectedSegmentIndex = 1
            self.handleViewModeChange()
        }
        DispatchQueue.global().async {
            WeatherServiceAPI.shared.fetchZipCodes(zipCodes: AppModel.sharedInstance.searchKeys)
        }
    }
}
