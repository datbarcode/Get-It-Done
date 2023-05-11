//
//  DataController.swift
//  GetItDone
//
//  Created by David Barko on 8/19/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import Foundation
import CoreData
// Holds persistent instance, load persistent store
// and access context.
class DataController {
    let persistentContainer:NSPersistentContainer
    // viewcontext property to access context
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // create persistent container instance
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    // load persistent container instance
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
