//
//  CollectionViewCell.swift
//  Unite Client
//
//  Created by Daniel Royer on 9/15/18.
//  Copyright © 2018 Union Interpretation Team (UnITe). All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var button: UIButton?
    
    var wasDone: Bool?
    
    func displayContent(toDoName: String, isDone: Bool, instance: ViewController)
    {
        //Creates a new button if one does not already exist
        if (button == nil)
        {
            //Creating a button with animation
            button = newButton(toDo: toDoName, isDone: isDone, instance: instance)
            UIView.animate(withDuration: 1, animations: {
                self.contentView.addSubview(self.button!)
            })
            //Adding constraints
            let xConstraint = NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            self.addConstraint(xConstraint)
            let widthConstraint = NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.size.width)
            self.addConstraint(widthConstraint)
            let heightConstraint = NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50)
            button!.addConstraint(heightConstraint)
        }
        
        //Display data on button
        button!.setTitle(toDoName, for: .normal)
        if (wasDone != isDone)
        {
            if (isDone)
            {
                UIView.animate(withDuration: 1.1, animations: {
                    self.button!.layer.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1).cgColor
                })
            }
            else
            {
                UIView.animate(withDuration: 1.1, animations: {
                    self.button!.layer.backgroundColor = UIColor.red.cgColor
                })
            }
            wasDone = isDone
        }
    }
    
    func newButton(toDo: String, isDone: Bool, instance: ViewController) -> UIButton
    {
        //Make a new button to return
        let toReturn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        //Set button action
        toReturn.addTarget(instance, action: #selector(instance.toggleButton), for: .touchUpInside)
        
        //Create and add a swipe gesture recognizer
        let swiper = UISwipeGestureRecognizer(target: instance, action: #selector(instance.doSwipe))
        swiper.delegate = instance
        swiper.direction = .left
        toReturn.addGestureRecognizer(swiper)
        
        //Set the button title and color
        toReturn.setTitle(toDo, for: .normal)
        if (isDone)
        {
            toReturn.layer.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1).cgColor
        }
        else {
            toReturn.layer.backgroundColor = UIColor.red.cgColor
        }
        
        //Make the button look good
        toReturn.layer.cornerRadius = 10
        toReturn.layer.borderWidth = 2
        toReturn.layer.borderColor = UIColor.white.cgColor
        toReturn.layer.shadowColor = UIColor.black.cgColor
        toReturn.layer.shadowOpacity = 0.2
        toReturn.layer.shadowRadius = 2
        toReturn.layer.shadowOffset = CGSize(width: 2, height: 2)
        toReturn.translatesAutoresizingMaskIntoConstraints = false
        
        //Return
        return toReturn
    }
}
