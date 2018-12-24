//
//  ViewController.swift
//  recol
//
//  Created by Brian on 9/18/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialDialogs

class ViewController: UITableViewController, UIViewControllerTransitioningDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate{
    
    /*****************************************
     * Variables
     *****************************************/
    var account: [NSManagedObject] = []
    var selectedAccountID: NSManagedObjectID!
    var manageObjectContext: NSManagedObjectContext!
    var globalSearchBar: globalSearchController!
    var searchPredicate: NSPredicate!
    var totalOfRecurring: Float! = 0.00
    
    /*****************************************
     * Outlets
     *****************************************/
    @IBOutlet var mainTableView: UITableView!
    
    /*****************************************
     * Init/View
     *****************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.2
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 6
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        let backgroundImage: UIImageView = UIImageView(image: UIImage(named: "Green Background"))
        backgroundImage.frame = self.view.frame
        backgroundImage.contentMode = .scaleAspectFill
        self.navigationController?.view.addSubview(backgroundImage)
        self.navigationController?.view.sendSubviewToBack(backgroundImage)
        
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //Bottom Bar View
        self.appBarDesign()

        //Add Search Bar
        self.globalSearchBar = globalSearchController(searchResultsController: nil)
        self.globalSearchBar.delegate = self
        self.globalSearchBar.searchBar.setTextFieldColor(color: UIColor.clear)
        self.globalSearchBar.searchBar.delegate = self
        self.globalSearchBar.searchBar.insideTextStyle(font: UIFont(name: "AvenirNext-Medium", size: 11)!)
        self.globalSearchBar.searchBar.placeholder = "Search for Account"
        self.globalSearchBar.searchBar.setTextFieldColor(color: UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0))
        let searchBar = self.globalSearchBar.searchBar.value(forKey: "searchField") as? UITextField
        searchBar?.sizeToFit()
        searchBar?.frame.size.height = 300
        searchBar?.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 253/255, alpha: 1)
        
        searchBar?.attributedPlaceholder = NSAttributedString(string: searchBar?.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        if let searchleftView = searchBar?.leftView as? UIImageView {
            searchleftView.image = searchleftView.image?.withRenderingMode(.alwaysTemplate)
            searchleftView.tintColor = UIColor.black
        }
        
        self.globalSearchBar.hidesNavigationBarDuringPresentation = false
        self.globalSearchBar.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = globalSearchBar.searchBar
        self.definesPresentationContext = true
        
        //TableView Settings
    
        //self.mainTableView.contentInset = UIEdgeInsets(top: 8.5, left: 0, bottom: 0, right: 0)
        
        //Register Custom Cells
        self.mainTableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTableViewCell")
        
        //Data Manipulation
        self.fetchCoreData()
        
        //Caculate Total of Recurring
        for accountAmount in account {
            let amount = accountAmount.value(forKey: "amount") as! Float
            totalOfRecurring += amount
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refreshControl?.beginRefreshing()
        self.refreshAccounts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*****************************************
     * Bottom App Bar
     *****************************************/
    func appBarDesign(){
        let appBarBottom = MDCBottomAppBarView()
        appBarBottom.frame = CGRect(x: 0, y: self.view.frame.height - 100, width: self.view.frame.width, height: 50)
        appBarBottom.floatingButton.setShadowColor(UIColor.lightGray, for: UIControl.State.normal)
        appBarBottom.shadowColor = UIColor.clear
        appBarBottom.floatingButton.backgroundColor = UIColor.white
        appBarBottom.barTintColor = UIColor.clear
        appBarBottom.floatingButton.setImage(UIImage(named: "Add Account"), for: UIControl.State.normal)
        appBarBottom.floatingButton.addTarget(self, action: #selector(addAccountSegue), for: UIControl.Event.touchUpInside)
        
        appBarBottom.autoresizingMask = .flexibleBottomMargin
        self.navigationController?.view.addSubview(appBarBottom)
    }
    
    @objc func addAccountSegue(){
        self.performSegue(withIdentifier: "addAccountView", sender: self)
    }
    
    /*****************************************
    * Search
    *****************************************/
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty{
            searchPredicate = NSPredicate(format: "name contains [c] '\(searchText)'")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
            fetchRequest.predicate = searchPredicate
            do {
                account = try context.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError {
                let alert = UIAlertController(title: "Alert", message: "Could not search account due to \(error). \(error.userInfo)", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
            }
        }else {
            fetchCoreData()
        }
        mainTableView.reloadData()
        
    }
    
    /*****************************************
     * No Data
     *****************************************/
    let noDataView = NoDataViewController()
    func noDataAppearence(){
        self.mainTableView.backgroundView = noDataView.view
    }
    
    /*****************************************
     * Core Data
     *****************************************/
    
    //Fetch CoreData
    func fetchCoreData(){
        //Fetch Accounts from CoreData
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        manageObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Account")
        do {
            account = try manageObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            let missingAlert = UIAlertController(title: "Alert", message: "Could not fetch your data \(error). \(error.userInfo)", preferredStyle: UIAlertController.Style.alert)
            self.present(missingAlert, animated: true, completion: nil)
        }
    }
    
    //Refresh Fetched Data
    func refreshAccounts(){
        fetchCoreData()
        self.mainTableView.reloadData()
    }
    
    /*****************************************
     * Table View
     *****************************************/
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        var accountAvailableSection: Int = 0
        if account.count > 0 {
            accountAvailableSection = 2
            mainTableView.backgroundView = nil
        } else {
            //No Data Appearence
            accountAvailableSection = 0
            self.noDataAppearence()
        }
        return accountAvailableSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return account.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nilCell = UITableViewCell()
        
        let account = self.account[indexPath.row]
        
        if indexPath.section == 0 {
            let cell = mainTableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell", for: indexPath) as! HeaderTableViewCell
            cell.totalRecurringAmount = CGFloat(totalOfRecurring)
            cell.totalOfAccounts = CGFloat(self.account.count)
            return cell
            
        }
        
        if indexPath.section == 1 {
            
            let cell = mainTableView.dequeueReusableCell(withIdentifier: "DefaultTableViewCell", for: indexPath) as! DefaultTableViewCell
            
            cell.backgroundColor = UIColor.clear
            
            let dateComponentsFormatter = DateComponentsFormatter()
            
            let duration = "\(dateComponentsFormatter.timeDifferenceCaculation(from: Date(), to: account.value(forKeyPath: "expireOn")! as! Date)!)"
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let expiration = formatter.string(from: account.value(forKey: "expireOn")! as! Date)
            
            cell.name!.text = account.value(forKeyPath: "name") as? String
            cell.expires.text = "Expire: \(expiration)"
            cell.amount!.text = "$\(String(format: "%.2f", account.value(forKey: "amount") as! Float))"
            cell.remaining.text = duration
            
            
            if account.value(forKey: "note")! as? String != "" {
                cell.noteAvailibility.isHidden = false
            } else {
                cell.noteAvailibility.isHidden = true
            }
            
            return cell
        }
        return nilCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let deleteItem = account[indexPath.row]
        if editingStyle == .delete {
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequest) in
                var identifiersArray: [String] = []
                for notification: UNNotificationRequest in notificationRequest {
                    if notification.identifier == "recol.\(deleteItem.value(forKeyPath: "name") as! String).account.due" {
                        identifiersArray.append(notification.identifier)
                    }
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersArray)
            }
            
            let Alert = MDCAlertController(title: "Deleted", message: "\(deleteItem.value(forKeyPath: "name") as! String) account was deleted.")
            Alert.addAction(MDCAlertAction(title: "Ok", handler: { (self) in
                print("Account deleted")
            }))
            self.present(Alert, animated: true, completion: nil)
            manageObjectContext.delete(deleteItem)
            do {
                try manageObjectContext.save()
            } catch let error as NSError {
                let alert = UIAlertController(title: "Alert", message: "Could not delete account due to \(error). \(error.userInfo)", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
            }
        }
        refreshAccounts()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAccountID = account[indexPath.row].objectID
        self.performSegue(withIdentifier: "addAccountView", sender: self.account[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 185
        }
        let account = self.account[indexPath.row]
        if account.value(forKey: "note")! as? String != "" {
            return 100
        } else {
            return 100 //Later Updat
        }
    }
    
    
    /*****************************************
     * Misc
     *****************************************/
    
    
    //Transition Control
    let sendBackAnimation = SendBackAnimationController()
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == "addAccountView" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self
            
            //Check if Account Selected is not Nil // Due to Menu Buttom Existence
            guard (sender as? Account) != nil else {
                return
                
            }
            //Pass Data if Selecting a Row
            let addAccountView = segue.destination as! AddViewController
            addAccountView.accountSelectedID = selectedAccountID
        }
    }
    
    //Transitions (Front & Back)
    let sendBackAnimationTransition = SendBackAnimationController()
    let sendFrontAnimationTransition = SendFrontAnimationController()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return sendBackAnimationTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return sendFrontAnimationTransition
    }

}

