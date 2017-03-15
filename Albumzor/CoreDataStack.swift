//
//  CoreDataStack.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/14/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let networkingContext: NSManagedObjectContext
    let context: NSManagedObjectContext //main queue (UI) context
    
    // MARK:- setup (init)
    
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Error building managed object model")
            return nil
        }
        self.modelURL = modelURL
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        networkingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        networkingContext.parent = context
        
        let fm = FileManager.default
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error finding documents directory")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    // MARK: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: options)
    }
    
    func save() {
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
}

extension CoreDataStack  {
    
    func dropAllData() throws {
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
    
}

//MARK:- Networking

extension CoreDataStack {
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    //"Batch" closure is responsible for calling save() on the networking context
    func performNetworkingOperation(_ batch: @escaping Batch) {
        networkingContext.perform() {
            batch(self.networkingContext)
        }
    }
    
}



