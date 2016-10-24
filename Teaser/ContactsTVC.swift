//
//  ContactsTVC.swift
//  Teaser
//
//  Created by Emil Shirima on 10/23/16.
//  Copyright © 2016 Emil Shirima. All rights reserved.
//

import UIKit
import Contacts

// TOTAL CONTACTS: 2991
// No Phone Numbers: 800
// No Names: 56
// Eligible: 430
// Useless: 1705

class ContactsTVC: UITableViewController
{
    var allContacts: [[CNContact]] = [[CNContact]]()
    
    let contactStore: CNContactStore = CNContactStore()
    
    var numberOfHeaders: Int = 0
    var userSelection = (contactsCategory: -1, isConfirmed: false)
    let tableHeaders: [String] = ["No Phone Numbers", "No Names", "Eligible Contacts", "Empty Contacts"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initiateArray()
        
        checkContactsAccess()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func initiateArray()
    {
        for _ in 0..<tableHeaders.count
        {
            allContacts.append([])
            
            numberOfHeaders += 1
        }
    }
    
    func checkContactsAccess()
    {
        switch CNContactStore.authorizationStatus(for: .contacts)
        {
        case .authorized:
            print("User Authorized")
            getAllContacts()
            
        case .denied:
            print("User Denied")
            
        case .notDetermined:
            print("Access not determined")
            requestContactAccess()
            
        case .restricted:
            print("Access restricted")
        }
    }
    
    func requestContactAccess()
    {
        contactStore.requestAccess(for: .contacts) { (result: Bool, error: Error?) in
            
            if error != nil
            {
                print("Error with contacts")
                print(error!.localizedDescription)
                return
            }
            
            print("Contacts result: \(result)")
            
            self.getAllContacts()
        }
    }
    
    func getAllContacts()
    {
        let request = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        
        do
        {
            try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact: CNContact, stop: UnsafeMutablePointer<ObjCBool>) in
                
                print(contact)
                
//                ["No Phone Numbers", "No Names", "The Rest", "Empty Contacts"]
                
                if contact.isUseless
                {
                    self.allContacts[self.numberOfHeaders - 1].append(contact)
                }
                else if contact.hasNoPhoneNumber
                {
                    self.allContacts[0].append(contact)
                }
                else if contact.hasNoName
                {
                    self.allContacts[1].append(contact)
                }
                else
                {
                    self.allContacts[self.numberOfHeaders - 2].append(contact)
                }
            })
        }
        catch let error
        {
            print("Unable to fetch contacts")
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.presentUserWithOptions()
            })
        }
    }
    
    func deleteContacts()
    {
        
    }
    
    func delete(contact: CNContact)
    {
        let saveRequest: CNSaveRequest = CNSaveRequest()
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        
        saveRequest.delete(mutableContact)
        
        do
        {
            try contactStore.execute(saveRequest)
            print("Contact Successfully Deleted")
        }
        catch let error
        {
            print("Error deleting contact")
            print(error.localizedDescription)
        }
    }
    
    func presentUserWithOptions()
    {
        let alertMenu: UIAlertController = UIAlertController(title: nil, message: "Choose Category", preferredStyle: .actionSheet)
        
        let deleteEmptyContactsAction: UIAlertAction = UIAlertAction(title: "Empty Contacts", style: .destructive) { (result: UIAlertAction) in
            
            self.userSelection = (self.numberOfHeaders - 1, false)
            self.confirmDeletion()
        }
        
        let deleteNoPhoneNumbersAction: UIAlertAction = UIAlertAction(title: "No Phone Numbers", style: .destructive) { (result: UIAlertAction) in
            
            self.userSelection = (0, false)
            self.confirmDeletion()
        }
        
        let deleteNoNamesAction: UIAlertAction = UIAlertAction(title: "No Names", style: .destructive) { (result: UIAlertAction) in
            
            self.userSelection = (1, false)
            self.confirmDeletion()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertMenu.addAction(deleteEmptyContactsAction)
        alertMenu.addAction(deleteNoPhoneNumbersAction)
        alertMenu.addAction(deleteNoNamesAction)
        alertMenu.addAction(cancelAction)
        
        present(alertMenu, animated: true, completion: nil)
    }
    
    func confirmDeletion()
    {
        let confirmAlert: UIAlertController = UIAlertController(title: "Confirm", message: "Are you sure you want to continue?", preferredStyle: .alert)
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { (result: UIAlertAction) in
            
            self.userSelection.isConfirmed = true
            self.deleteContacts()
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        confirmAlert.addAction(deleteAction)
        confirmAlert.addAction(cancelAction)
        
        present(confirmAlert, animated: true, completion: nil)
    }
}

extension ContactsTVC
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return allContacts.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return allContacts[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return tableHeaders[section] + " (\(allContacts[section].count))"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("User selected (sec,row): \(indexPath.section), \(indexPath.row)")
        print(allContacts[indexPath.section][indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = allContacts[indexPath.section][indexPath.row].givenName
        cell.detailTextLabel?.text = allContacts[indexPath.section][indexPath.row].middleName
        
        return cell
    }
}

extension CNContact
{
    var isUseless: Bool
    {
        if self.givenName.isEmpty && self.phoneNumbers.isEmpty && self.emailAddresses.isEmpty
        {
            return true
        }
        
        return false
    }
    
    var hasNoPhoneNumber: Bool
    {
        if !self.givenName.isEmpty && self.phoneNumbers.isEmpty
        {
            return true
        }
        
        return false
    }
    
    var hasNoName: Bool
    {
        if self.givenName.isEmpty
        {
            return true
        }
        
        return false
    }
}
