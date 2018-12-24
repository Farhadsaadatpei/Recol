//
//  AddViewController.swift
//  recol
//
//  Created by Brian on 9/18/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import SwiftValidator
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialDialogs
import MaterialComponents.MaterialButtons


class AddViewController: UIViewController, UITextFieldDelegate, ValidationDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    /*****************************************
     * Variables
     *****************************************/
    var accountSelectedID: NSManagedObjectID!
    var previousDuration: Int!
    var addButtonIsUpdate: Bool! = false
    var dayPickerData = ["Day", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th", "21st", "22nd", "23rd", "24th", "25th", "26th", "27th", "28th", "29th", "30th"]
    var dayPickerSelectionChange: Int?
    
    
    /*****************************************
     * Outlets
     *****************************************/
    
    @IBOutlet weak var editType: UILabel!
    @IBOutlet weak var typeHint: UILabel!
    @IBOutlet weak var name: MDCTextField!
    @IBOutlet weak var duration: MDCTextField!
    @IBOutlet weak var dayPicker: UIPickerView!
    @IBOutlet weak var amount: MDCTextField!
    @IBOutlet weak var note: MDCMultilineTextField!
    //UPDATE 1.1 @IBOutlet weak var notification: UISwitch!
    @IBOutlet weak var addButton: UIButton!
    
    /*****************************************
     * Views Actions
     *****************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notification Authorization
        self.notificationSettings()
        
        //Day Picker
        self.dayPickerInit()
        
        //Hide Keyboard on Touch
        self.hideKeyboardWhenTappedAround()

        //Text Fields
        self.textFieldInit()
        
        //Edit Type Check
        self.editingType()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*****************************************
     * Notification
     *****************************************/
    //Notification
    func notificationSettings(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in}
    }
    
    //Create Notification
    func createNotification(name: String, day: Int){
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Account Due"
        notificationContent.body = "\(name) account is up for due this month."
        notificationContent.badge = 1
        
        let createOnDateWithDayInput = Calendar.current.date(bySetting: .day, value: day, of: Date())
        let monthlyTriggerDay = Calendar.current.dateComponents([.day], from: createOnDateWithDayInput!)
        print(monthlyTriggerDay)
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: monthlyTriggerDay, repeats: true)
        let notificationRequest = UNNotificationRequest(identifier: "recol.\(name).account.due", content: notificationContent, trigger: notificationTrigger)
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: nil)
    }
    
    //Remove Notitifcation
    func removeNotification(name: String){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequest) in
            var identifiersArray: [String] = []
            for notification: UNNotificationRequest in notificationRequest {
                if notification.identifier == "recol.\(name).account.due" {
                    identifiersArray.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
        }
    }
    
    /*****************************************
     * Day Picker
     *****************************************/
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dayPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dayPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dayPickerSelectionChange = row
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as! UILabel?
        if label == nil {
            label = UILabel()
        }
        
        let title = NSAttributedString(string: dayPickerData[row], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!

    }
    
    // Day Picker Settings
    func dayPickerInit(){
        self.dayPicker.delegate = self
        self.dayPicker.dataSource = self
    }
    
    /*****************************************
     * Text Fields
     *****************************************/
    
    //Text Field Theme Settings
    let borderColor = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1)
    let placeHolderInactiveColor = UIColor.black
    let placeHolderActiveColor = UIColor.black
    let borderColorActiveValid = UIColor(red: 77/255, green: 185/255, blue: 100/255, alpha:  1)
    let borderColorActiveInavlid = UIColor.red
    
    //Validation Init
    let validator = Validator()
    
    //Field Metrial Design Init
    let nameStyle = MDCTextInputControllerOutlined()
    let durationStyle = MDCTextInputControllerOutlined()
    let amountStyle = MDCTextInputControllerOutlined()
    let dayStyle = MDCTextInputControllerOutlined()
    let noteStyle = MDCTextInputControllerOutlinedTextArea()
    
    func textFieldInit(){
        
        //Field Delegates
        self.name.delegate = self
        self.duration.delegate = self
        self.amount.delegate = self
        
        //Register Field with Validation
        validator.registerField(textField: name, rules: [RequiredRule()])
        validator.registerField(textField: duration, rules: [RequiredRule(), MaxLengthRule(length: 3)])
        validator.registerField(textField: amount, rules: [RequiredRule()])
        
        //Name Field
        nameStyle.textInput = name
        nameStyle.inlinePlaceholderColor = placeHolderInactiveColor
        nameStyle.borderFillColor = borderColor
        nameStyle.textInput?.clearButtonMode = .never
        
        //Duration Field
        durationStyle.textInput = duration
        durationStyle.inlinePlaceholderColor = placeHolderInactiveColor
        durationStyle.borderFillColor = borderColor
        durationStyle.textInput?.clearButtonMode = .never
        
        //Amount Field
        amountStyle.textInput = amount
        amountStyle.inlinePlaceholderColor = placeHolderInactiveColor
        amountStyle.borderFillColor = borderColor
        amountStyle.textInput?.clearButtonMode = .never
        
        //Note Field
        noteStyle.textInput = note
        noteStyle.inlinePlaceholderColor = placeHolderInactiveColor
        noteStyle.borderFillColor = borderColor
        noteStyle.placeholderText = "Write something..."
    }
    
    func validationSuccessful() {
        self.addButton.backgroundColor = UIColor(red: 77/255, green: 185/255, blue: 100/255, alpha: 1)
        self.addButton.isUserInteractionEnabled = true
    }
    
    
    
    func validationFailed(errors: [UITextField : ValidationError]) {
        self.addButton.backgroundColor = UIColor.lightGray
        self.addButton.isUserInteractionEnabled = false       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        switch textField {
        case duration: //Duration Type Settings
            let length = (textField.text! as NSString).replacingCharacters(in: range, with: string).count
            if length > 3 { return false }
            guard CharacterSet(charactersIn: "123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        case amount: //Amount Type Settings
            let length = (textField.text! as NSString).replacingCharacters(in: range, with: string).count
            if length > 10 { return false }
            guard CharacterSet(charactersIn: "0123456789.").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        default:
            break
        }
        validator.validate(delegate: self)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        validator.validate(delegate: self)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        validator.validate(delegate: self)
        return true
    }
    
    
    /*****************************************
     * Manage Account
     *****************************************/
    
    //Add New Account
    @IBAction func accountAction(_ sender: Any) {
        //Check for Notification Status and Convert into Boolean type
        if addButtonIsUpdate == true  {
            //Update the Account
            if dayPickerSelectionChange == nil {
                updateAccount(name: name.text!, duration: Int(duration!.text!)!, day: 1, amount: Float(amount!.text!)!, note: note.text!)
            }else {
                updateAccount(name: name.text!, duration: Int(duration!.text!)!, day: dayPickerSelectionChange!, amount: Float(amount!.text!)!, note: note.text!)
            }
        } else {
            //Save New Account
            if dayPickerSelectionChange == nil {
                saveAccount(name: name.text!, duration: Int(duration!.text!)!, day: 1, amount: Float(amount!.text!)!, note: note.text!)
            }else {
                saveAccount(name: name.text!, duration: Int(duration!.text!)!, day: dayPickerSelectionChange!, amount: Float(amount!.text!)!, note: note.text!)
            }
           
            
        }
    }
    
    
    //Save Account
    func saveAccount(name: String, duration: Int, day: Int, amount: Float, note: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedContext)
        let account = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        //Set values
        account.setValue(Date(), forKey: "createdOn")
        account.setValue(name, forKey: "name")
        account.setValue(duration, forKey: "duration")
        account.setValue(amount, forKey: "amount")
        account.setValue(day, forKey: "day")
        account.setValue(note, forKey: "note")
        //UPDATE 1.1 account.setValue(notification, forKey: "notification")
        
        //Expiration Calculation
        var dateComponent = DateComponents()
        dateComponent.month = Int(duration)
        let expirationDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        let expirationDateWithDayInput = Calendar.current.date(bySetting: .day, value: day, of: expirationDate!)
        account.setValue(expirationDateWithDayInput, forKey: "expireOn")
        
        //Create Notification
        self.createNotification(name: name, day: day)
        
        do {
            try managedContext.save()
            dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            let Alert = UIAlertController(title: "Alert", message: "You're missing field(s). \(error)", preferredStyle: UIAlertController.Style.alert)
            self.present(Alert, animated: true, completion: nil)
        }
    }
    
    //Update Account
    func updateAccount(name: String, duration: Int, day: Int,  amount: Float, note: String){
        
        //Remove Notification
        self.removeNotification(name: name)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        fetchRequest.predicate = NSPredicate()
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        do {
            let accountUpdate = try managedContext.existingObject(with: accountSelectedID)
            accountUpdate.setValue(name, forKey: "name")
            
            //Expiration Date
            var dateComponent = DateComponents()
            dateComponent.month = Int(duration)
            let expirationDate = Calendar.current.date(byAdding: dateComponent, to: Date())
            let expirationDateWithDayInput = Calendar.current.date(bySetting: .day, value: day, of: expirationDate!)
            accountUpdate.setValue(expirationDateWithDayInput, forKey: "expireOn")
            print("New Expiratin Data Recorded")
            
            accountUpdate.setValue(duration, forKey: "duration")
            accountUpdate.setValue(day, forKey: "day")
            accountUpdate.setValue(amount, forKey: "amount")
            accountUpdate.setValue(note, forKey: "note")
            try managedContext.save()
            
            //Create Notification
            createNotification(name: name, day: day)
            
            //Alert Update Successful
            let Alert = MDCAlertController(title: "Updated", message: "Account was updated successfully.")
            let alertAction = MDCAlertAction(title: "Ok") { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            Alert.addAction(alertAction)
            self.present(Alert, animated: true, completion: nil)
            
        }catch let error as NSError {
            //Error Update unsuccessful
            let Alert = MDCAlertController(title: "Oops!", message: "Account Couldn't be Updated. \(error)")
            let alertAction = MDCAlertAction(title: "Dismiss") { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            Alert.addAction(alertAction)
            self.present(Alert, animated: true, completion: nil)
        }
    }
    
    func editingType(){
        self.typeHint.text = ""
        //Check if User is Editing an Account
        if accountSelectedID == nil {
            self.editType.text = "New Account"
            self.typeHint.text = "Yes! More Money, Less Problems."
            self.addButton.backgroundColor = UIColor.lightGray
            self.addButton.isUserInteractionEnabled = false
            //LATER NEED UPDATE HERE
            
        } else {
            
            self.editType.text = "Updating Account"
            self.typeHint.text = "Updates overwrite inputs. Name can't be changed."
            
            guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                let accountUpdate = try managedContext.existingObject(with: accountSelectedID)
                self.name.text = accountUpdate.value(forKey: "name") as? String
                self.name.isUserInteractionEnabled = false
                self.duration.text = String(accountUpdate.value(forKey: "duration") as! Int)
                self.dayPicker.selectRow(accountUpdate.value(forKey: "day") as! Int, inComponent: 0, animated: true)
                self.dayPickerSelectionChange = accountUpdate.value(forKey: "day") as? Int
                self.previousDuration = Int(accountUpdate.value(forKey: "duration") as! Int)
                self.amount.text = String(format: "%.2f", accountUpdate.value(forKey: "amount") as! Float)
                self.note.text = accountUpdate.value(forKey: "note") as? String
                
    
                addButton.setTitle("Update", for: UIControl.State.normal)
                addButtonIsUpdate = true
            } catch let error as NSError {
                let Alert = MDCAlertController(title: "Error", message: "Couldn't retrieve the selected account. \(error)")
                Alert.addAction(MDCAlertAction(title: "Dismiss", handler: { (self) in
                    print("Couldn't retrieve the account. \(error)")
                }))
                self.present(Alert, animated: true, completion: nil)
            }
        }
    }
    
}

