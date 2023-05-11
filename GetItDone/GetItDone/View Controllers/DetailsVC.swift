//
//  DetailsVC.swift
//  GetItDone
//
//  Created by David Barko on 7/22/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import UIKit
import CoreData
class DetailsVC: UIViewController, UITableViewDelegate, UITextViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var addTheSubTask: UIButton!
    @IBOutlet weak var DescriptionView: UITextView!
    @IBOutlet weak var nameText: UITextView!
    @IBOutlet weak var placeHolder: UILabel!
    
    // flags used for prepare segue
    // flag = 1 -> subtask is nil/new
    // isnew = 1 -> task is nil/new
    var flag = 0
    var isNew = false
    var subTaskEditMode = true
    @IBOutlet weak var taskNamePlaceHolder: UILabel!
    
    @IBAction func addSubtask(_ sender: Any) {
        let subTask = Subtask(context: dataController.viewContext)
        subTask.task = task
        task.desc = DescriptionView.text
        subTask.status = 0
        subTask.name = "New Subtask"
        subtasks.append(subTask)
        try? dataController.viewContext.save()
        tableView2.reloadData()
        flag = 1
        performSegue(withIdentifier: "toSubDetailsVC", sender: nil)
    }

    @objc func backBtn(_ sender: Any) {
                let alert = UIAlertController(title: "New Task", message: "Enter a name for this Task", preferredStyle: .alert)
        
        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
               // let task = Task(context: self!.dataController.viewContext)
            self!.task.name = self!.nameText.text
            self!.task.desc = self!.DescriptionView.text
            try? self!.dataController.viewContext.save()
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        updateProgress()
        self.navigationController?.popViewController(animated: true)
    }
    
    var task: Task!
    var subtasks: [Subtask] = []

    var dataController:DataController!
    //let imgButtonBg = UIImage(named: "Add Task.png")

   
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubTaskBtn()
        taskNamePlaceHolder.isHidden = true
        self.hideKeyboardWhenTappedAround()
        nameText.text = task.name
        DescriptionView.delegate = self
        //placeHolder.isHidden = false
       // DescriptionView.textColor = UIColor.black
        //DescriptionView.backgroundColor = UIColor.white
        //Making placeholder appear for empty descriptions

    
        // Add save button to navigation
        if(isNew == true){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonClicked))
            subTaskEditMode = true
            placeHolder.isHidden = false
        }
        else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(startEdit))
            nameText.isEditable = false
            DescriptionView.isEditable = false
            //addTheSubTask.isHidden = true
            subTaskEditMode = false
        }
        //description text border
        //UIColor borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        tableView2.delegate = self
        tableView2.dataSource = self
//        if nameText.text.isEmpty == true{
//            taskNamePlaceHolder.isHidden = false
//            taskNamePlaceHolder.text = "Task Name"
//            taskNamePlaceHolder.textColor = UIColor.lightGray
//        }
//        else{
//            taskNamePlaceHolder.isHidden = true
//        }
        if((task.desc?.isEmpty) == true){
            placeHolder.isHidden = false
            placeHolder.text = "Description"
            placeHolder.textColor = UIColor.lightGray
        }
        else{
            placeHolder.isHidden = true
            DescriptionView.text = task.desc
        }
        getData()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeHolder.isHidden = true
        //taskNamePlaceHolder.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if (DescriptionView.text.isEmpty){
            placeHolder.isHidden = false
        }
//        if nameText.text.isEmpty{
//            taskNamePlaceHolder.isHidden = false
//            taskNamePlaceHolder.text = "Task Name"
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        flag = 0
        // Observe notification from subdetailsVC
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData2"), object: nil)
    }
    // Fetches all data after removing old
    @objc func getData() {
        nameText.text = task.name
        //DescriptionView.text = task.desc
        subtasks.removeAll(keepingCapacity: false)
        let fetchRequest:NSFetchRequest<Subtask> = Subtask.fetchRequest()
        let predicate = NSPredicate(format: "task == %@", task)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            subtasks = result
            tableView2.reloadData()
        }
        task.numSub = Int16(subtasks.count)
        try? dataController.viewContext.save()
        if(isNew){
            placeHolder.isHidden = false
            placeHolder.text = "Description"
            placeHolder.textColor = UIColor.lightGray
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
    }
    
    
    // Align and set appearance of + button
    func setSubTaskBtn() {
       // addTheSubTask.setImage(imgButtonBg, for: .normal)
        addTheSubTask.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.fill
        addTheSubTask.layer.cornerRadius = addTheSubTask.frame.height / 4
        tableView2.register(SubTaskViewCell.nib(), forCellReuseIdentifier: SubTaskViewCell.identifier)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfSubtasks
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aSubtask = subtasks[indexPath.row]
        let cell = tableView2.dequeueReusableCell(withIdentifier: SubTaskViewCell.identifier, for: indexPath) as! SubTaskViewCell
        cell.configure(with: aSubtask.name!, stat: aSubtask.status, enabled: subTaskEditMode)
        cell.delegate = self
        return cell
    }
    // segue to subdetailsvc when existing subtask clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSubDetailsVC", sender: nil)
    }
    @objc func startEdit() {
        nameText.isEditable = true
        DescriptionView.isEditable = true
        addTheSubTask.isHidden = false
        subTaskEditMode = true
         self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButtonClicked))
        tableView2.reloadData()
    }
    // Creates new subtask/changes existing name
    @objc func saveButtonClicked() {
            task.name = nameText.text
            task.desc = DescriptionView.text
        try? dataController.viewContext.save()
        // Once saved, send notification to mainVC to update data
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        if isNew == true{
        self.navigationController?.popViewController(animated: true)
        } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(startEdit))
        subTaskEditMode = false
        nameText.isEditable = false
        DescriptionView.isEditable = false
        tableView2.reloadData()
        }
    }
    // Deletes subtask
    func deleteSubTask(at indexPath: IndexPath) {
        let taskToDelete = subtasks[indexPath.row]
        dataController.viewContext.delete(taskToDelete)
        try? dataController.viewContext.save()
        subtasks.remove(at: indexPath.row)
        tableView2.deleteRows(at: [indexPath], with: .fade)
        if numberOfSubtasks == 0 {
            setEditing(false, animated: true)
        }
        tableView2.reloadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //This is the menu that pops up when a long hold on a task
       func tableView(_ tableView: UITableView,
                      contextMenuConfigurationForRowAt indexPath: IndexPath,
                      point: CGPoint) -> UIContextMenuConfiguration? {
           
           let favorite = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")){ (action) in
               print("Refresh the data.")
           }
           let share = UIAction(title: "Edit", image: UIImage(systemName: "pencil")){ (action) in
               
               print("Edit the data.")
           }
           let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")){ (action) in
               
               self.dataController.viewContext.delete(self.subtasks[indexPath.row])
               do {
                   try self.dataController.viewContext.save()
                  } catch {
                      print("Error in saving to coreData")
                  }
               self.subtasks.remove(at: indexPath.row)
               self.tableView2.reloadData()
           }
           
           return UIContextMenuConfiguration(identifier: nil,
                                             previewProvider: nil) { _ in
                                               UIMenu(title: "Actions", children: [favorite, share, delete])
           }
       }
       
    // Calls deleteSubtask when delete pressed
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteSubTask(at: indexPath)
        default: ()
        }
        updateProgress()
        
    }
    var numberOfSubtasks: Int {return subtasks.count}
    // Prepare before segue, flag = 1, subtask is nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SubDetailsVC {
            if flag == 1 {
                vc.task = task
                vc.subtask = subtasks[subtasks.count-1]
                vc.dataController = dataController
                vc.subTask = subtasks[subtasks.count-1]
                vc.newSubTask = true
            }
            else if let indexPath = tableView2.indexPathForSelectedRow {
                vc.task = task
                vc.subtask = subtasks[indexPath.row]
                vc.dataController = dataController
                vc.subTask = subtasks[indexPath.row]
                vc.newSubTask = false
            }
        }
    }
    func updateProgress(){
        task.numSub = Int16(numberOfSubtasks)
        let doneCount = subtasks.filter{$0.status == 2}.count
        task.numSubDone = Int16(doneCount)
        try? dataController.viewContext.save()
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
    }
}
// delegate used to change color of status indicator
// on subtask cell
extension DetailsVC: SubStatusDelegate {
    func subStatusClicked(cell: SubTaskViewCell) {
        if let indexPath = self.tableView2.indexPath(for: cell) {
            if subtasks[indexPath.row].status == 0 {
                cell.subStatusbtn.layer.backgroundColor = UIColor.systemYellow.cgColor
                cell.subStatusbtn.layer.borderWidth = 0.0
                subtasks[indexPath.row].status = 1
            } else if subtasks[indexPath.row].status == 1 {
                cell.subStatusbtn.layer.backgroundColor = UIColor.systemGreen.cgColor
                cell.subStatusbtn.layer.borderWidth = 0.0
                subtasks[indexPath.row].status = 2
            } else {
                cell.subStatusbtn.layer.backgroundColor = cell.taskBackView.layer.backgroundColor
                cell.subStatusbtn.layer.borderWidth = 0.5
                subtasks[indexPath.row].status = 0
            }
            task.numSub = Int16(numberOfSubtasks)
            let doneCount = subtasks.filter{$0.status == 2}.count
            task.numSubDone = Int16(doneCount)
            try? dataController.viewContext.save()
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        }
    }
}
