//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Places>!
    private var filteredPlaces: Results<Places>!
    private var ascendingSorting = true
    private var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonSorted: UIBarButtonItem!
    @IBOutlet var segmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Places.self)
        
        //Setup search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.isActive = false
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        } else {
            return places.isEmpty ? 0 : places.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        var place = Places()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }

        cell.nameLabelCell.text = place.name
        cell.locationLabelCell.text = place.location
        cell.typeLabelCell.text = place.type
        
        let image = UIImage(data: place.imageData!)
        
        cell.imageCell.image = image

        cell.imageCell.layer.cornerRadius = cell.imageCell.frame.size.height / 2
        cell.imageCell.clipsToBounds = true

        return cell
    }
    
    
    // MARK: - Delete place
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteContextualAction = [UIContextualAction(
            style: .destructive,
            title: "Delete") { _, _, _  in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }]
        
        let swipeActions = UISwipeActionsConfiguration(actions: deleteContextualAction)
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailPlace" {
            
            guard let cellIndexPath = tableView.indexPathForSelectedRow else { return }
            
            var cell = Places()
            
            if isFiltering {
                cell = filteredPlaces[cellIndexPath.row]
            } else {
                cell = places[cellIndexPath.row]
            }
            
            guard let NewPlaceTVC = segue.destination as?
                    NewPlaceTableViewController else { return }
            
            NewPlaceTVC.detailPlace = cell
        }
        
    }

    @IBAction func unwidSegue(_ unwindSegue: UIStoryboardSegue) {
        
        guard let newPlaceVC = unwindSegue.source
                as? NewPlaceTableViewController else { return }
        
        newPlaceVC.savePlace() 
        tableView.reloadData()
    }
    
    // MARK: - Sorting Places
    @IBAction func sortedSegmented(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func sortedButton(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            buttonSorted.image = UIImage(named: "AZ")
        } else {
            buttonSorted.image = UIImage(named: "ZA")
        }
        
        sorting()
    }
    
    private func sorting() {
        
        if segmented.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}


extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
