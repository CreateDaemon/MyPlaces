//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 28.09.21.
//

import UIKit

class NewPlaceTableViewController: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var choiceImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let photoIcon = UIImage(named: "photo")
            let cameraIcon = UIImage(named: "camera")
            
            let actionSheat = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheat.addAction(camera)
            actionSheat.addAction(photo)
            actionSheat.addAction(cancel)
            
            present(actionSheat, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - savePlace
    func savePlace() -> Places {
        
        let place: Places
        
        if choiceImage {
            place = Places(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageEntertaiment: nil, image: placeImage.image)
        } else {
            place = Places(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageEntertaiment: nil, image: UIImage(named: "imagePlaceholder"))
        }
        
        return place
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true)
    }
}

    // MARK: - TextFiledDelegate
    
    extension NewPlaceTableViewController: UITextFieldDelegate {
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
        
        @objc private func textFieldChange () {
            
            if placeName.text != "" {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Work with image
extension NewPlaceTableViewController: UIImagePickerControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        choiceImage = true
        dismiss(animated: true)
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
