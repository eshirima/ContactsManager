//
//  ContactsTVC.swift
//  Teaser
//
//  Created by Emil Shirima on 10/23/16.
//  Copyright © 2016 Emil Shirima. All rights reserved.
//

import UIKit
import Contacts

class ContactsTVC: UITableViewController
{
    var allContacts: [[CNContact]] = [[CNContact]]()
    
    let contactStore: CNContactStore = CNContactStore()
    
    let tableHeaders: [String] = ["Empty Contacts", "No Phone Numbers", "The Rest"]
    
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
//        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        
//        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
        
        let request = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        
        do
        {
            try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact: CNContact, stop: UnsafeMutablePointer<ObjCBool>) in
                
                print(contact)
                print("Contact GN: \(contact.givenName)")
                
                if contact.isUseless
                {
                    self.allContacts[0].append(contact)
                }
                else
                {
                    self.allContacts[1].append(contact)
                }
            })
        }
        catch
        {
            print("Unable to fetch contacts")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        print("Contacts size: \(allContacts.count)")
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
//        if section == 0 // empty contacts
//        {
//            return emptyContacts.count
//        }
        
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
}
