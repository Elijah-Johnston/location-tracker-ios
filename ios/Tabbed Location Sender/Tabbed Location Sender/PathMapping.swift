//
//  Path.swift
//  Tabbed Location Sender
//
//  Created by Eli Johnston on 2020-07-10.
//  Copyright © 2020 Eli Johnston. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PathMapping: NSObject, NSCoding {
    
    var route : [[Double]] = [[]]
    var waypoints : [[Double]] = [[]]
    var name: String
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    init(name: String, route: [[Double]]) {
        self.route = route
        self.name = name
        super.init()
    }
    
    init(name: String, route: [[Double]], waypoints: [[Double]]) {
        self.route = route
        self.waypoints = waypoints
        self.name = name
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.route = aDecoder.decodeObject(forKey: "route") as! [[Double]]
        self.waypoints = aDecoder.decodeObject(forKey: "waypoints") as! [[Double]]
        self.name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(route, forKey: "route")
        aCoder.encode(waypoints, forKey: "waypoints")
        aCoder.encode(name, forKey: "name")
    }
    
    func setRoute(route: [[Double]]) {
        self.route = route
    }
    
    func setWaypoints(waypoints: [[Double]]) {
        self.waypoints = waypoints
    }
    
    func getRoute() -> [[Double]] {
        return self.route
    }
    
    func getWaypoints() -> [[Double]] {
        return self.waypoints
    }
    
    func appendRoute(location: [Double]) {
        self.route.append(location)
    }
    
    func save() throws {
//        if (retrieveByName(name: self.name) != nil) {
//            throw "Name already exists"
//        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let mappingEntity = NSEntityDescription.entity(forEntityName: "MappingCoordinates", in: managedContext)!
        let mappingCoords = NSManagedObject(entity: mappingEntity, insertInto: managedContext) as! MappingCoordinates

        let pathMap = PathMapping(name: self.name, route: self.route, waypoints: self.waypoints)
        
        mappingCoords.setValue(pathMap, forKey: "path")
        mappingCoords.name = pathMap.name
            
         do {
             try managedContext.save()
         } catch let error as NSError {
             print("Could not save. \(error), \(error.userInfo)")
         }
     }
    
    func retrieveAllPaths() -> [PathMapping]? {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
         let managedContext = appDelegate.persistentContainer.viewContext
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MappingCoordinates")

         do {
            let pathObjs = try managedContext.fetch(fetchRequest)
            var paths = [] as [PathMapping]
            for element in pathObjs {
                let singlePath = (element as! NSManagedObject).value(forKey: "path") as! PathMapping
                paths.append(singlePath)
            }
            return paths
         } catch {
            print("Failed")
            return nil
         }
     }
    
    func retrieveByName(name: String) -> PathMapping? {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
         let managedContext = appDelegate.persistentContainer.viewContext
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MappingCoordinates")

         // fetchRequest.fetchLimit = 1
         fetchRequest.predicate = NSPredicate(format: "name == %@", name)
         // fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
         do {
            let result = try managedContext.fetch(fetchRequest)
            if result.count > 0 {
                let object = result[0] as! NSManagedObject
                return object.value(forKey: "path") as? PathMapping
            } else {
                print("RECORD NOT FOUND")
                return nil
            }
         } catch {
            print("Failed")
            return nil
         }
     }
    
    func updateByName(name: String, path: PathMapping) {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
         let managedContext = appDelegate.persistentContainer.viewContext
         let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MappingCoordinates")
         fetchRequest.predicate = NSPredicate(format: "name == %@", name)
         do
         {
             let test = try managedContext.fetch(fetchRequest)
            
             if test.count > 0 {
                 let objectUpdate = test[0] as! NSManagedObject
                 objectUpdate.setValue(path, forKey: "path")
             } else {
                 print("RECORD NOT FOUND")
             }
             
             do {
                 try managedContext.save()
             }
             catch {
                 print(error)
             }
         }
         catch {
             print(error)
         }

     }

    func deleteByName(name: String) {
         guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
         let managedContext = appDelegate.persistentContainer.viewContext
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MappingCoordinates")
        
         fetchRequest.predicate = NSPredicate(format: "name == %@", name)

         do
         {
             let test = try managedContext.fetch(fetchRequest)

             if test.count > 0 {
                 let objectToDelete = test[0] as! NSManagedObject
                 managedContext.delete(objectToDelete)
             } else {
                 print("RECORD NOT FOUND")
             }

             do {
                 try managedContext.save()
             }
             catch {
                 print(error)
             }
         }
         catch {
             print(error)
         }
     }
}

extension String: Error {}
