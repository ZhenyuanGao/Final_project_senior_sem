//
//  kevin_DB.swift
//  Milestone_1_test3
//
//  Created by Kevin Gao on 4/4/20.
//  Copyright © 2020 Kevin Gao. All rights reserved.
//

import SQLite
class kevin_DB{
    static let instance = kevin_DB()
    private let db: Connection?
    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let phone = Expression<String>("phone")
    private let address = Expression<String>("address")
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!

        do {
            db = try Connection("\(path)/Stephencelis.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }

        createTable()
    }

    func createTable() {
        do {
            try db!.run(contacts.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(name)
            table.column(phone, unique: true)
            table.column(address)
            })
        } catch {
            print("Unable to create table")
        }
    }

    func addContact(cname: String, cphone: String, caddress: String) -> Int64? {
        do {
            let insert = contacts.insert(name <- cname, phone <- cphone, address <- caddress)
            let id = try db!.run(insert)
            print(insert.asSQL())

            return id
        } catch {
            print("Insert failed")
            return -1
        }
        
    }
    func getContacts() -> [Contact] {
        var contacts = [Contact]()

        do {
            for contact in try db!.prepare(self.contacts) {
                contacts.append(Contact(
                id: contact[id],
                name: contact[name]!,
                phone: contact[phone],
                address: contact[address]))
            }
        } catch {
            print("Select failed")
        }

        return contacts
    }
    func deleteContact(cid: Int64) -> Bool {
        do {
            let contact = contacts.filter(id == cid)
            try db!.run(contact.delete())
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    func updateContact(cid:Int64, newContact: Contact) -> Bool {
        let contact = contacts.filter(id == cid)
        do {
            let update = contact.update([
                name <- newContact.name,
                phone <- newContact.phone,
                address <- newContact.address
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }

        return false
    }
}
