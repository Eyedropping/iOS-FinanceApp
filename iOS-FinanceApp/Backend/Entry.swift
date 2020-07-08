//
//  Entry.swift
//  iOS-FinanceApp
//
//  Created by Dmitry Aksyonov on 02.07.2020.
//  Copyright © 2020 Dmitry Aksyonov. All rights reserved.
//

import Foundation
import RealmSwift

/**
 '@objcMembers' exposes all class members, extensions, subclasses and their extensions to Objective-C code
 this adversely affects performance, thus not recommended
 ~> '@objc' used instead (does the same thing but for the individual member of the class)
 */
class Entry: Object {
    // MARK: - Entry Persisted Properties
    enum Property: String {
        case id, name, amount, date, category, entryType, creationStamp
    }
    
    /**
     'dynamic' engages the dynamic method dispatch to deal with the property (theory below)
     - method dispatch: mechanism that selects the appropriate method implementation to be called, breaks down in following types:
     - dynamic dispatch: engaged on runtime, thus some overhead, breaks down in two types:
     - table (virtual) dispatch: creates the witness (virtual) table (an array of function pointers) ~> looks up appropriate implemetation address. Performs in 3 steps:
     (1) read the pointer address,
     (2) jump to the address location,
     (3) perform instruction (faster than message dispatch)
     - message dispatch: most dynamic way of invocation, it's behavior can be altered at runtime (method swizzling),
     - static (direct) dispatch: instruction locations detected @ compile time, compiler accesses instruction directly (fast, but slower than inline dispatch) so no overhead ar run time bc func overriding is not allowed in this case ~> no need to make a table
     - inline dispatch (fastest): (@inline) - inlining the code into the dispatch [NEEDS CLARIFICATION]
     */
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var amount: Int = 0
    @objc dynamic var date: Date?
    @objc dynamic var strDate: String? /* {
     Butler.createDateFormatter(dateStyle: .medium, timeStyle: .none).string(from: date!)
     }*/
    @objc dynamic var category: String?
    @objc dynamic var entryType: String?
    @objc dynamic var creationStamp: String?
    
    // MARK: - Custom Init to Add an Entry
    /**
     convenience init - secondary supporting initializer [SOMEHOW NOW THIS IS THE ONLY WAY TO INIT REALM INSTANCE ~> NEEDS CLARIFICATION]
     */
    convenience init(id: String, name: String, amount: Int, date: Date, category: String, entryType: String?, ToC: String) {
        self.init()
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.strDate = Heplers.createDateFormatter(dateStyle: .medium, timeStyle: .none).string(from: date)
        self.category = category
        self.entryType = entryType
        self.creationStamp = ToC
    }
    
    // MARK: - Entry Description
    override var description: String {
        get {
            return """
            \nid: \(id ?? "");
            name: \(name ?? "");
            amount: \(amount);
            date: \(date ?? Date());
            type: \(entryType ?? "");
            category: \(category ?? "");
            ToC: \(creationStamp ?? "").
            """
        }
    }
    
    // MARK: - Entry Primary Key
    /*
     can be used to edit some of the object's property ~> EntryInsertion
     
     let person = MyPerson()
     person.personID = "My-Primary-Key"
     person.name = "Tom Anglade"
     
     Update `person` if it already exists, add it if not.
     
     let realm = try! Realm()
     try! realm.write {
     realm.add(person, update: true)
     }
     
     [CONSIDER IMPLEMENTATION]
     */
    override static func primaryKey() -> String {
        return Entry.Property.id.rawValue
    }
}