//
//  ViewController.swift
//  Telemachus
//
//  Created by Jacob Gaffney on 13/07/2016.
//  Licensed under the GPL v3
//

import Cocoa
import Contacts

class ViewController: NSViewController {

    @IBOutlet var numberField: NSTextField!
    @IBOutlet var messageField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure our textfields' purpose is clear to the user
        numberField.placeholderString = "Phone Number"
        messageField.placeholderString = "Write a Message..."
        
        
        // This will be our dictionary for names and numbers
        var namesAndNumbers = [String: String]()
        
        // This block makes sure we only collect mobile numbers for our list
        for contact in contacts{
            if contact.phoneNumbers.first?.value != nil {
                let phoneNumber = CommunicationTools.validateNumber((contact.phoneNumbers.first?.value as? CNPhoneNumber)!.stringValue)
                let fullname = CNContactFormatter.stringFromContact(contact, style: .FullName)
                
                // Only mobile numbers, thanks!
                if phoneNumber.characters.count > 8{
                    namesAndNumbers[fullname!] = phoneNumber
                }
            }
        }
        
        // Create a dictionary that's sorted alphabetically by key and includes values
        let sortedNamesAndNumbers = namesAndNumbers.sort { $0.0 < $1.0}
        
        // Just a test
        for (name, number) in sortedNamesAndNumbers {
            print("\(name) - \(number)")
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // What happens when you click the send button
    @IBAction func sendMessage(sender: NSButton) {
        // Send our SMS
        CommunicationTools.smsCommand(numberField.stringValue, messageTextField: messageField.stringValue)
        
        // Clean up the form
        print("clearing inputs")
        clearFields()
    }
    
    // Let's collect our contacts from different containers
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactPhoneNumbersKey]
        
        // Collect all containers, in the event user has more than one
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Collect all the contacts from each of these containers
        var results: [CNContact] = []
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                
                // Collect the contact information we need
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        // This value should be all of our contacts, albeit unformatted and full of extra stuff
        return results
    }()
    
    
    
    // Clean up fields
    func clearFields() {
        numberField.stringValue = ""
        messageField.stringValue = ""
    }
    
}

