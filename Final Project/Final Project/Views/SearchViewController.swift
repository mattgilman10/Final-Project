//
//  SearchViewController.swift
//  Final Project
//
//  Created by Matthew Gilman on 4/7/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<SearchItem>!
    
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var dropDown: UIPickerView!
    @IBOutlet weak var searchBox: UITextField!
    
    var keyboardOnScreen = false
    var list = ["1", "2", "3", "5", "5", "3"]
    var locationList: Array<String> = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        grabList()
        searchBox.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIResponder.keyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIResponder.keyboardDidHideNotification, selector: #selector(keyboardDidHide))
        
        setupSearch()
    }
    
    // MARK: Setup search
    private func setupSearch(){
        let fetchRequest:NSFetchRequest<SearchItem> = SearchItem.fetchRequest()
        // display all of the saved data
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            if result != []{
                self.textBox.text = result[0].location
                self.searchBox.text = result[0].searchField
            }
        }
        
    }
    
    // grabs the list from the input file
    
    private func grabList() {
        // Read the contents of the specified file
        let contents = try! String(contentsOfFile: "/Users/matthewgilman/Documents/IOS Degree/Final-Project/Final Project/Final Project/craigslist.txt")
        // Split the file into separate lines
        let lines = contents.split(separator:"\n")
        
        // Iterate over each line and print the line
        for line in lines {
            //print("\(line)")
            locationList.append(String(line))
        }
        return
    }
    
    @IBAction func submitSearch(_ sender: Any) {
        if searchBox.text != nil && textBox.text != nil{
            let fetchRequest:NSFetchRequest<SearchItem> = SearchItem.fetchRequest()
            if self.textBox.text! != nil && self.searchBox.text != nil{
                addSearch()
                 let predicate = NSPredicate(format: "location == %@ and searchField == %@", argumentArray: [self.textBox.text!, self.searchBox.text!])
                fetchRequest.predicate = predicate
                
                if let result = try? dataController.viewContext.fetch(fetchRequest),
                    let newSearch = result.first {
                    performSegue(withIdentifier: "GO", sender: newSearch)
                }
            }
            else{
                showMessageToUser(title: "Invalid Entry", msg: "You must fill in both fields")
            }
            
            
//            let controller = self.storyboard!.instantiateViewController(withIdentifier: "SearchedResultViewController") as! SearchedResultViewController
//            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: Segue to the next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NotesListViewController, we'll configure its `Notebook`
        let DestViewController = segue.destination as! UINavigationController
        if let vc = DestViewController.topViewController as? SearchedResultViewController {
            let newSearch = sender as? SearchItem
            vc.searchItem = newSearch
            vc.dataController = dataController
        }
    }
    
    //Mark add new location to core data
    func addSearch(){
        let newSearch = SearchItem(context: dataController.viewContext)
        newSearch.searchField = self.searchBox.text
        newSearch.location = self.textBox.text
        try? dataController.viewContext.save()
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return locationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return locationList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.textBox.text = self.locationList[row]
        let selection = self.locationList[row]
        print(selection)
        self.dropDown.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.textBox {
            self.dropDown.isHidden = false
            //if you don't want the users to se the keyboard type:
            
            textField.endEditing(true)
        }
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            //view.frame.origin.y = keyboardHeight(notification)
            //movieImageView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
}

    

private extension SearchViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Mark: Error Message
    func showMessageToUser(title: String, msg: String)  {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// -------------------------------------------------------------------------

