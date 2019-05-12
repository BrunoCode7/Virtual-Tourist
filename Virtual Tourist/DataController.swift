//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/12/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistantContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistantContainer.viewContext
    }
    
    init(modelName:String) {
        persistantContainer=NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
}
