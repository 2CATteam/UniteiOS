//
//  ViewController.swift
//  Unite Client
//
//  Created by Daniel Royer on 8/10/18.
//  Copyright © 2018 Union Interpretation Team (UnITe). All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    
    //References to items in the storyboard
    
    @IBOutlet weak var buttonCollector: UICollectionView!
    @IBOutlet weak var refreshButton: UIButton!
    
    //Arrays that together make up an ordered pseudo-dictionary
    var toDos: [String] = []
    var states: [Bool] = []
    
    //Basic setup
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshButton.addTarget(self, action: #selector(updateButtonSet), for: .touchUpInside)
        updateButtonSet()
    }
    
    @objc func updateButtonSet()
    {
        //Builds a GET request to a server with the To-Dos and states
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //Constructs the task from the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //Parses data into the toDos and states fields
            guard data != nil else {return}
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
            self.toDos = jsonObj?.allKeys as! [String]
            print(self.toDos)
            self.toDos.sort()
            self.states = [Bool](repeating: true, count: self.toDos.endIndex)
            for x in self.toDos.startIndex..<self.toDos.endIndex
            {
                self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
            }
            //Refreshes the views
            DispatchQueue.main.async {
                self.buttonCollector.reloadData()
                //self.buttonCollector.setNeedsDisplay()
                print("Updated")
            }
        }
        //Starts the task
        task.resume()
    }
    
    func addNewToDo(toDoSet: String) {
        //Construct a PUT request with the new toDo, initialized to be not done.
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        json[toDoSet] = false
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //Parses data into the toDos and states fields
                guard data != nil else {return}
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.toDos = jsonObj?.allKeys as! [String]
                self.toDos.sort()
                self.states = [Bool](repeating: true, count: self.toDos.endIndex)
                for x in self.toDos.startIndex..<self.toDos.endIndex
                {
                    self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                }
                //Refreshes the views
                DispatchQueue.main.async {
                    self.buttonCollector.reloadData()
                    //self.buttonCollector.setNeedsDisplay()
                    print("Adding")
                }
            }
            task.resume()
        } catch {
            
        }
    }
    
    @objc func toggleButton(sender: UIButton!) {
        //Get button information to send a PUT request to switch the button state when pressed
        let toDoName = sender.title(for: .normal)
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        let index = toDos.index(of: toDoName!)
        
        states[index!] = !states[index!]
        
        json[toDoName!] = states[index!]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //Parses data into the toDos and states fields
                guard data != nil else {return}
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.toDos = jsonObj?.allKeys as! [String]
                self.toDos.sort()
                self.states = [Bool](repeating: true, count: self.toDos.endIndex)
                for x in self.toDos.startIndex..<self.toDos.endIndex
                {
                    self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                }
                //Refreshes the views
                DispatchQueue.main.async {
                    self.buttonCollector.reloadData()
                    //self.buttonCollector.setNeedsDisplay()
                    print("Toggled")
                }
            }
            task.resume()
        } catch {
            
        }
    }
    
    @objc func doSwipe(sender: UIGestureRecognizer!)
    {
        //Sends a DELETE request to remove the toDo when swiped
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        //First must get name of toDo by accessing the button tied to the swipeGestureRecognizer
        if (sender.view?.isKind(of: UIButton.self))!
        {
            let button = sender.view as! UIButton
            json[button.title(for: .normal)!] = true
            do {
                
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                var request = URLRequest(url: url!)
                request.httpMethod = "DELETE"
                request.httpBody = data
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    //Parses data into the toDos and states fields
                    guard data != nil else {return}
                    let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    self.toDos = jsonObj?.allKeys as! [String]
                    self.toDos.sort()
                    self.states = [Bool](repeating: true, count: self.toDos.endIndex)
                    for x in self.toDos.startIndex..<self.toDos.endIndex
                    {
                        self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                    }
                    //Refreshes the views
                    DispatchQueue.main.async {
                        self.buttonCollector.reloadData()
                        //self.buttonCollector.setNeedsDisplay()
                        print("Deleted")
                    }
                }
                
                task.resume()
            } catch {
                
            }
        }
        else
        {
            print("ERROR! THIS IS NOT A BUTTON!")
        }
    }
    
    @IBAction func addButtonPushed(_ sender: UIButton!) {
        //Throw up an alert asking for a new toDo, then add it initialized to false
        let alert = UIAlertController(title: "Enter To-Do", message: "Please type the name of this list item the way you would like it to appear on your list", preferredStyle: .alert)
        alert.addTextField {
            (textField) in textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.addNewToDo(toDoSet: (textField?.text!)!)
            print("Text field: \(textField?.text ?? "null")")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField?.text ?? "null")")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //We have only one section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Sets the number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toDos.endIndex
    }
    
    //Gives the view its cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = buttonCollector.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.displayContent(toDoName: toDos[indexPath.row], isDone: states[indexPath.row], instance: self)
        
        return cell
    }
    
    //These items should not be able to be moved
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //Sets the cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
    }
}

