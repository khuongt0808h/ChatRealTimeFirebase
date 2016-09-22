//
//  ListFood.swift
//  ChatDemo
//
//  Created by Khuong Luu on 9/20/16.
//  Copyright © 2016 Khuong Luu. All rights reserved.
//

import Foundation

class ListFood: UITableViewController{
    
    
    var items: [FoodItem] = []
    let ref = FIRDatabase.database().referenceWithPath("FoodItem")
    var user: User!
    
    let usersRef = FIRDatabase.database().referenceWithPath("online")
    var userCountBarButtonItem: UIBarButtonItem!
    var signOutBarButtonItem: UIBarButtonItem!
    
    var viewToolBar: UIView =  UIView()
    var txfContentType: UITextField = UITextField()
    var btnSend: UIButton = UIButton()
    
//    viewToolBar.ba
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("list data : \(ref)")
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .Plain,
                                                 target: self,
                                                 action: nil)
        userCountBarButtonItem.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        signOutBarButtonItem = UIBarButtonItem(title: "Sign Out",
                                                 style: .Plain,
                                                 target: self,
                                                 action: #selector(actionSignOut))
        signOutBarButtonItem.tintColor = UIColor.blackColor()
        navigationItem.rightBarButtonItem = signOutBarButtonItem
        
        usersRef.observeEventType(FIRDataEventType.Value, withBlock: {snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        
            
        })
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({(auth, user) in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        })
        
        
        ref.queryOrderedByChild("FoodItem").observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            
            var newItems: [FoodItem] = []
            
            for item in snapshot.children {
                let foodItem = FoodItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(foodItem)
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
        
        //MARK  set frame view tool bar
//        viewToolBar.fra
        viewToolBar.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 115, UIScreen.mainScreen().bounds.width, 50)
        viewToolBar.backgroundColor = UIColor.blueColor()
        
        //add textfield
        txfContentType.frame = CGRectMake(10.0, 10.0, UIScreen.mainScreen().bounds.width - 80, 30.0)
        txfContentType.backgroundColor = UIColor.whiteColor()
        txfContentType.delegate = self
        viewToolBar.addSubview(txfContentType)
        
         btnSend.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 60, 7.0, 55, 35.0)
        btnSend.backgroundColor = UIColor.grayColor()
        btnSend.setTitle("Send", forState: UIControlState.Normal)
        btnSend.titleLabel?.textColor = UIColor.whiteColor()
        btnSend.addTarget(self, action: #selector(actionAddNew), forControlEvents: UIControlEvents.TouchUpInside)
        viewToolBar.addSubview(btnSend)
        
        self.view.addSubview(viewToolBar)
    }
    
    
    // MARK: delegate table view
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        var cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Subtitle, reuseIdentifier: "ItemCell")
        }

        // Fetches the appropriate meal for the data source layout.
        let foodItem = self.items[indexPath.row]
        
        cell.textLabel?.text = foodItem.name
        cell.detailTextLabel?.text = foodItem.addedByUser
        
        print("User \(foodItem.addedByUser)")
        
        toggleCellCheckbox(cell, isCompleted: foodItem.completed)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let foodItem = items[indexPath.row]
            foodItem.ref?.removeValue()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        let foodItem = items[indexPath.row]
        let toggledCompletion = !foodItem.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        foodItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
    }
    
    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        } else {
            cell.accessoryType = .Checkmark
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
    }
    
    
    //MARK action add new
    @IBAction func actionAddNew(sender: AnyObject) {
        
        guard let text = txfContentType.text else { return }
        
        let groceryItem = FoodItem(name: text,
                                      addedByUser: self.user.email,
                                      completed: false)
        // 3
        let groceryItemRef = self.ref.child(text)
        
        // 4
        groceryItemRef.setValue(groceryItem.toAnyObject())
        
    }
    

   // MARK  sign out
    @IBAction func actionSignOut(sender: AnyObject) {
        
        do {
            try FIRAuth.auth()!.signOut()
//            dismiss(animated: true, completion: nil)
            self.usersRef.child(self.user.uid).removeValue()
            self.navigationController?.popToRootViewControllerAnimated(true)
        } catch {
            
        }
    }
}

extension ListFood: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txfContentType {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
