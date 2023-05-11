//
//  ViewController.swift
//  GetItDone
//
//  Created by David Barko on 7/22/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //let imgButtonBg = UIImage(named: "Task Btn.png")
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addTaskBtn: UIButton!
    
    var tasks: [Task] = []
    
    var dataController:DataController!
    // TO DO: flag is used to check if the cell clicked is the addtaskbtn
    // figure out a better way to do this
    var flag = 0
    
    @IBAction func addTaskBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "New Task", message: "Enter a name for this Task", preferredStyle: .alert)
        
        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                let task = Task(context: self!.dataController.viewContext)
                task.name = name
                self!.self.flag = 1
                self!.tasks.append(task)
                try? self!.dataController.viewContext.save()
                
                self!.performSegue(withIdentifier: "toDetailsVC", sender: nil)
            }
        }
        saveAction.isEnabled = false
        
        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddTaskBtn()
        getData()
        self.hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "Tasks"
        
    }
    // Fetches Data
    @objc func getData() {
        tasks.removeAll(keepingCapacity: false)
        let fetchRequest:NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            tasks = result
            tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // Observer notification for "newData", execute getData if observed
        flag = 0
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    // Setup addbtntask appearance
    func setAddTaskBtn() {
        //addTaskBtn.setImage(imgButtonBg, for: .normal)
        addTaskBtn.layer.cornerRadius = addTaskBtn.frame.height / 6
        tableView.register(MainTableViewCell.nib(), forCellReuseIdentifier: MainTableViewCell.identifier)
    }

    // Count number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfTasks
    }
    // Add cells to tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aTask = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        // Calls configure function in MainTableViewCell.swift
        cell.configure(with: aTask.name!, subTotal: aTask.numSub, subDone: aTask.numSubDone)
        return cell
    }
    // Performs segue when an existing task is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    // Deletes Task
    func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        dataController.viewContext.delete(taskToDelete)
        try? dataController.viewContext.save()
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if numberOfTasks == 0 {
            setEditing(false, animated: true)
        }
    }
    // Deletes task when delete button clicked
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteTask(at: indexPath)
        default: ()
        }
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
               
               self.dataController.viewContext.delete(self.tasks[indexPath.row])
               do {
                   try self.dataController.viewContext.save()
                  } catch {
                      print("Error in saving to coreData")
                  }
               self.tasks.remove(at: indexPath.row)
               self.tableView.reloadData()
           }
           
           return UIContextMenuConfiguration(identifier: nil,
                                             previewProvider: nil) { _ in
                                               UIMenu(title: "Actions", children: [favorite, share, delete])
           }
       }
       
    
    var numberOfTasks: Int {return tasks.count}
    // Preparations before segue, flag = 1 -> task is nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsVC {
            if flag == 1 {
                vc.isNew = true
                vc.task = tasks[tasks.count-1]
                vc.dataController = dataController
            }
            else if let indexPath = tableView.indexPathForSelectedRow {
                vc.task = tasks[indexPath.row]
                vc.dataController = dataController
            }
        }
    }

}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

