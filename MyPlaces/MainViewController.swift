//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var places: Results<Places>!
    var ascendingSorting = true
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var buttonSorted: UIBarButtonItem!
    @IBOutlet var segmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Places.self)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let plase = places[indexPath.row]

        cell.nameLabelCell.text = plase.name
        cell.locationLabelCell.text = plase.location
        cell.typeLabelCell.text = plase.type
        
        let image = UIImage(data: plase.imageData!)
        
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
            let cell = places[cellIndexPath.row]
            
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
