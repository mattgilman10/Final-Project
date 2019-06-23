//
//  SearchedResultViewController.swift
//  Final Project
//
//  Created by Matthew Gilman on 4/27/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyXMLParser

class SearchedResultViewController: UIViewController {
    
    // MARK: Class Variables
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Item>!
    var searchItem: SearchItem!
    
    // MARK: UI Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Fetch result controller
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Item> = Item.fetchRequest()
        print("searchItem: \(searchItem!)")
        let predicate = NSPredicate(format: "searchItem == %@", searchItem!)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "issued", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(searchItem!)-item")
        //change this later no need for NSFetchedResult thing
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Initial loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false

        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0{
            grabSearch()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: Cancel button
    @IBAction func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Grab data from API
    private func grabSearch(){
        CraigslistClient.sharedInstance().taskForGETMethod(region: searchItem.location!, search: searchItem.searchField!) { (success, results, error) in
            if success == false{
                self.showMessageToUser(title: "Error", msg: "Could not load data")
                return
            }
            for item in results{
                self.parseSingleResult(item)
            }
//            self.tableView.reloadData()
        }
    }
    
    // MARK: Parse the xml.accessor given back from api call
    private func parseSingleResult(_ result: XML.Accessor){
        if let title = result["title"].text, let bio = result["description"].text, let date = result["dcterms:issued"].text, let link = result["link"].text {
            
            let dateFormatter = ISO8601DateFormatter()
            let newDate = dateFormatter.date(from:date)!

            if let image = result["enc:enclosure"].attributes["resource"]{
                let url = URL(string: image)
                if let imageData = try? Data(contentsOf: url!) {
                    let newTitle = String(htmlEncodedString: title)
                    self.addItem(link: link, image: imageData, bio: bio, date: newDate, title: newTitle)
                }
            }
        }
    }
    
    // MARK: Add the Item to core data
    private func addItem(link: String, image: Data, bio: String, date:Date, title: String){
        let item = Item(context: dataController.viewContext)
        item.bio = bio
        item.issued = date
        item.title = title
        item.url = link
        item.image = image
        item.searchItem = self.searchItem
        try? dataController.viewContext.save()
    }
    
    // Mark: Error Message
    func showMessageToUser(title: String, msg: String)  {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - Table view data source
extension SearchedResultViewController:UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aItem = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell.defaultReuseIdentifier, for: indexPath) as! itemCell
        cell.activityIndidicator.startAnimating()
        
        cell.titleLabel.text = aItem.title
        cell.bioLabel.text = aItem.bio
        cell.cellImage.image = UIImage(data: aItem.image!)
        
        cell.activityIndidicator.stopAnimating()
        cell.activityIndidicator.isHidden = true
        

//        print("I AM IN HERE creating my cell")
        return cell
    }
    // MARK: Selected Row load craigslist website
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemClicked = fetchedResultsController.object(at: indexPath)
        let url = URL(string: itemClicked.url!)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }else{
            showMessageToUser(title: "URL Issue", msg: "Cannot open this ad. Please try a different one")
        }
        
    }
    
    
    
}

// MARK: Adding core data to the UITableView
extension SearchedResultViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: self.tableView.insertSections(indexSet, with: .fade); print("yes")
        case .delete: self.tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

// MARK: For parsing assistance with the xml.accessor and html data
extension String {
    
    init(htmlEncodedString: String) {
        self.init()
        guard let encodedData = htmlEncodedString.data(using: .utf8) else {
            self = htmlEncodedString
            return
        }
        
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self = attributedString.string
        } catch {
            print("Error: \(error)")
            self = htmlEncodedString
        }
    }
}
