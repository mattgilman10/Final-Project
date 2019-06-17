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

class SearchedResultViewController: UIViewController {
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Item>!
    var searchItem: SearchItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Fetch result controller
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "searchItem == %@", searchItem)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        //change this later no need for NSFetchedResult thing
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        // get the app delegate
        //appDelegate = UIApplication.shared.delegate as! AppDelegate
        parent!.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(goBack))
        
        print(searchItem.location!)
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0{
            grabSearch()
        }
        
        // get the correct genre id
        //genreID = genreIDFromItemTag(tabBarItem.tag)
        
        // create and set logout button
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    @IBAction func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func grabSearch(){
        CraigslistClient.sharedInstance().taskForGETMethod(region: searchItem.location!, search: searchItem.searchField!) { (success, results, error) in
            if success == false{
                self.showMessageToUser(title: "Error", msg: "Could not load data")
                return
            }
        }
    }
    
    // Mark: Error Message
    func showMessageToUser(title: String, msg: String)  {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - Table view data source
extension SearchedResultViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aItem = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: adCell.defaultReuseIdentifier, for: indexPath) as! adCell
        
        //        // Configure cell
        //        cell.nameLabel.text = aNotebook.name
        //
        //        if let count = aNotebook.notes?.count {
        //            let pageString = count == 1 ? "page" : "pages"
        //            cell.pageCountLabel.text = "\(count) \(pageString)"
        //        }
        
        return cell
    }
    
    
}

extension SearchedResultViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
