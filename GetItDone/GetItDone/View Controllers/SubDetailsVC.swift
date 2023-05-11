//
//  SubDetailsVC.swift
//  GetItDone
//
//  Created by David Barko on 8/27/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import UIKit
import CoreData
class SubDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var nameText: UITextView!
    @IBOutlet weak var descView: UITextView!
    var subTask: Subtask!
    var newSubTask: Bool!
 //   var images: [Images] = []
    var dataController: DataController!
    @IBOutlet weak var addImageButton: UIButton!
    @IBAction func addImage(_ sender: Any) {
       
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        {
                let img = Images(context: dataController.viewContext)
                img.subTask = subTask
                img.img = image.pngData()
                //images.append(img)
                try? dataController.viewContext.save()
                newSubTask = false
                ImageCollection.reloadData()
        }
        else{
            print("error adding image")
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var ImageCollection: UICollectionView!
    
    var numberOfImages: Int {return imagesFromCoreData().count}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aImg = imagesFromCoreData()[indexPath.row]
        let cell = ImageCollection.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.configure(with: aImg.img!)
        return cell
    }
    
    
    var largeImage: UIImage!
    var selectedIndexPath: IndexPath!
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        largeImage = UIImage(data: imagesFromCoreData()[indexPath.row].img!)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "toImageVC", sender: nil)
    }
    var ip: IndexPath!
    func contextMenuPreview() -> UIViewController {
      let vc = UIViewController()
      
      // 1
        let imageView = UIImageView(image: largeImage)
        vc.view = imageView
      
      // 2
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 400)
      imageView.translatesAutoresizingMaskIntoConstraints = false
      
      // 3
      vc.preferredContentSize = imageView.frame.size
      
      return vc
    }
    
    //making context menu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")){ (action) in
            self.largeImage = UIImage(data: self.imagesFromCoreData()[indexPath.row].img!)
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toImageVC", sender: nil)
        }
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive){ (action) in
            self.dataController.viewContext.delete(self.imagesFromCoreData()[indexPath.row])
            do {
                try self.dataController.viewContext.save()
               } catch {
                   print("Error in saving to coreData")
               }
            self.getData()
            }
        self.largeImage = UIImage(data: self.imagesFromCoreData()[indexPath.row].img!)
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: contextMenuPreview) { _ in
                                            UIMenu(title: "Actions", children: [edit, delete])
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        nameText.text = subtask.name
        descView.text = subtask.desc
        ImageCollection.delegate = self
        ImageCollection.dataSource = self
        addImageButton.isHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonClicked))
        if !newSubTask{
            getData()
            //ImageCollection.reloadData()
        }
    }
    var changedImage: UIImage!
    var indexPathOfChangedImage: IndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newImage(_:)), name: NSNotification.Name("newData4"), object: nil)
    }
    @objc func contextObjectsDidChange(_ notification: Notification) {
        print(notification)
        
    }
    @objc func newImage(_ notification: NSNotification) {
           print(notification.userInfo ?? "")
           if let dict = notification.userInfo as NSDictionary? {
               if let id = dict["image"] as? UIImage{
                let imageToDel = imagesFromCoreData()[selectedIndexPath.row]
                self.dataController.viewContext.delete(imageToDel)
                let img = Images(context: dataController.viewContext)
                img.subTask = subTask
                img.img = id.pngData()
                try? dataController.viewContext.save()
                getData()
               }
           }
    }
    @objc func getData() {
        ImageCollection.reloadData()
//        //nameText.text = task.name
//        //DescriptionView.text = task.desc
//        addImageButton.isHidden = false
//        //images.removeAll(keepingCapacity: false)
//        let fetchRequest:NSFetchRequest<Images> = Images.fetchRequest()
//        let predicate = NSPredicate(format: "subTask == %@", subTask)
//        fetchRequest.predicate = predicate
//        let sortDescriptor = NSSortDescriptor(key: "img", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//           // images = result
//            ImageCollection.reloadData()
//        }
//        try? dataController.viewContext.save()
//        newSubTask = false
    }
    
    @objc func imagesFromCoreData() -> [Images] {
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
        newSubTask = false
        return tempImages
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let popoverViewController = segue.destination as? ViewImageVC  {
            popoverViewController.img = largeImage
            popoverViewController.dataController = dataController
            popoverViewController.selectedPath = selectedIndexPath
            //popoverViewController.images = imagesFromCoreData()
            popoverViewController.subTask = subTask
            //addImageButton.isHidden = true
         }
    }
    @IBAction func backBtn(_ sender: Any) {
        
    }
    var task: Task!
    var subtask: Subtask!
   // var dataController:DataController!
    var isNew = false
    //saves subtask, isnew = 1 -> create new subtask
    @objc func saveButtonClicked() {
        if isNew == true {
            let newSubtask = Subtask(context: dataController.viewContext)
            newSubtask.name = nameText.text
            newSubtask.desc = descView.text
            newSubtask.task = task
            newSubtask.status = 0
        } else {
            subtask.name = nameText.text
            subtask.desc = descView.text
        }
        try? dataController.viewContext.save()
        NotificationCenter.default.post(name: NSNotification.Name("newData2"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
     }
}
extension SubDetailsVC: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let size = CGSize(width: 100, height: 100)
            return size
        }
    }
