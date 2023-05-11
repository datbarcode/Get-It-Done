//
//  ViewImage.swift
//  GetItDone
//
//  Created by David Barko on 1/6/21.
//  Copyright © 2021 David Barko. All rights reserved.
//
import UIKit
import CoreData

class ViewImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var dataController: DataController!
    var selectedPath: IndexPath!
    //var images: [Images]!
    var subTask: Subtask!
    
    
    func imagesFromCoreData() -> [Images] {
        //nameText.text = task.name
       
        var tempImages: [Images] = []
        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
        let predicate = NSPredicate(format: "subTask == %@", subTask)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "img", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            tempImages = result
            //ImageCollection.reloadData()
        }
        //try? dataController.viewContext.save()
        return tempImages
    }
    @IBAction func DeleteBtn(_ sender: Any) {
        
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) { (action) in
            let imageToDel = self.imagesFromCoreData()[self.selectedPath.row]
            self.dataController.viewContext.delete(imageToDel)
            try? self.dataController.viewContext.save()
            NotificationCenter.default.post(name: NSNotification.Name("newData3"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel",
                                     style: .cancel) { (action) in
         // Respond to user selection of the action
        }
        let alert = UIAlertController(title: "Are you sure?",
                       message: "This cannot be undone!",
                       preferredStyle: .actionSheet)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true){
            
        }
    }
    
    @IBAction func EditBtn(_ sender: Any) {
        let image = UIImagePickerController()
        
        let camera = UIAlertAction(title: "Camera",
                  style: .default) { (action) in
            image.sourceType = .camera
            image.delegate = self
            image.allowsEditing = true
            self.present(image, animated: true)
        }
        let photoLib = UIAlertAction(title: "Photo Library",
                                     style: .default) { (action) in
            image.sourceType = .photoLibrary
            image.delegate = self
            image.allowsEditing = true
            self.present(image, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel",
                                     style: .cancel) { (action) in
         // Respond to user selection of the action
        }
        let alert = UIAlertController(title: "Source",
                       message: "Choose the source of the photo",
                       preferredStyle: .actionSheet)
        alert.addAction(camera)
        alert.addAction(photoLib)
        alert.addAction(cancel)
        
        self.present(alert, animated: true){
            
        }
        
    }
    var newImageSent:[String: UIImage]!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        {
            newImageSent = ["image": pickedImage]
//            let imageToDel = self.images[self.selectedPath.row]
//            self.dataController.viewContext.delete(imageToDel)
            //try? self.dataController.viewContext.save()
            image.image = pickedImage
        }
        else{
            print("error adding image")
        }
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name("newData4"), object: nil, userInfo: newImageSent)
    }
    @IBOutlet weak var image: UIImageView!
    var img: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        image.layer.cornerRadius = 8.0
        image.clipsToBounds = true
        image.image = img
    }
}
