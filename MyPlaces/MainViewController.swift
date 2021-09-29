//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import UIKit

class MainViewController: UITableViewController {

    var places = Places.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        let plase = places[indexPath.row]
        
        cell.nameLabelCell.text = plase.name
        cell.locationLabelCell.text = plase.location
        cell.typeLabelCell.text = plase.type
        
        if plase.image != nil {
            cell.imageCell.image = plase.image
        } else {
            cell.imageCell.image = UIImage(named: plase.name)
        }
        
        cell.imageCell.layer.cornerRadius = cell.imageCell.frame.size.height / 2
        cell.imageCell.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        85
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwidSegue(_ unwindSegue: UIStoryboardSegue) {
        
        guard let newPlaceVC = unwindSegue.source
                as? NewPlaceTableViewController else { return }
        let newPlace = newPlaceVC.savePlace()
        places.append(newPlace)
        tableView.reloadData()
    }
    
}
