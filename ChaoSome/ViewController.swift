//
//  ViewController.swift
//  ChaoSome
//
//  Created by Alumno on 14/06/18.
//  Copyright © 2018 Alumno. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    var index = 0
    var array: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc func willEnterForeground(){
        loadPlist()
        loadCore()
        index = Int(arc4random_uniform(UInt32(array.count)))
        print("Index: \(index)")
        label.text = array[index] as? String
    }

    override func viewWillAppear(_ animated: Bool) {
        loadPlist()
        loadCore()
        index = Int(arc4random_uniform(UInt32(array.count)))
        print("Index: \(index)")
        label.text = array[index] as? String
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadPlist() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let path = documentsDirectory.appendingPathComponent("Default.plist")
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path){
            if let bundlePath = Bundle.main.path(forResource: "Default", ofType: "plist") {
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }
                catch {
                    print("Error: failed loading plist")
                }
            }
        }
        
        array = NSMutableArray(contentsOfFile: path)!
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New greeting", message: "Add a new greeting", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Save", style: .default){
            [unowned self] action in
            guard let textField = alert.textFields?.first, let text = textField.text else{
                return
            }
            self.save(text: text)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addTextField()
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func save(text: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "WholeText", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(text, forKeyPath: "text")
        do{
            try managedContext.save()
            array.add(text)
        } catch let error as NSError{
            print("Couldn't save data. \(error), \(error.userInfo)")
        }
    }
    
    func loadCore(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WholeText")
        
        do{
            let array2 = try managedContext.fetch(fetchRequest)
            for i in array2{
                array.add(i.value(forKeyPath: "text") as! String)
            }
        } catch {
            print("Couldn't load core data")
        }
    }
    
    
}

