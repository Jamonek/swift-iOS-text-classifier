//
//  ClassifierVC.swift
//  Text Classifier
//
//  Created by Jamone Alexander Kelly on 11/25/15.
//  Copyright © 2015 Jamone Kelly. All rights reserved.
//

import UIKit
import Parsimmon
import RealmSwift

class ClassifierVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var trainButton: UIButton!
    @IBOutlet var classifyButton: UIButton!
    let realm = try! Realm()
    @IBOutlet var trainTextField: UITextField!
    @IBOutlet var trainCategoryField: UITextField!
    @IBOutlet var classifyTextField: UITextField!
    lazy var classifier = NaiveBayesClassifier()
    @IBOutlet var classifyResultTextField: UILabel!
    var classifierData : Results<CData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate our data
        self.populate()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Attach functions to our buttons
        self.trainButton.addTarget(self, action: "trainClassifier:", forControlEvents: .TouchUpInside)
        self.classifyButton.addTarget(self, action: "classify:", forControlEvents: .TouchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func populate() {
        let data = realm.objects(CData)
        
        if data.count == 0 {
            print("No data")
            self.classifierData = nil
            return
        }
        
        self.classifierData = data
        
        // We have our data..
        guard let count = self.classifierData?.count else {
            return
        }
        
        // Our data is available.. lets train
        for i in 0..<count {
            if let cellData = self.classifierData?[i] {
                self.classifier.trainWithText(cellData.text, category: cellData.category)
                NSLog("Train Category: \(cellData.category) - Text: \(cellData.text)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.classifierData == nil {
            return 0
        }
        
        return (self.classifierData?.count)!
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ClassifierCVCell
        
        if let cellData = self.classifierData?[indexPath.row] {
            cell.text.text = cellData.text
            cell.category.text = cellData.category
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("test")
    }
    
    func trainClassifier(sender: UIButton) {
        // Check for input
        guard let trainingText = self.trainTextField.text where !trainingText.isEmpty else {
            print("Missing training text")
            return
        }
        
        guard let trainingCategory = self.trainCategoryField.text where !trainingCategory.isEmpty else {
            print("Missing training category")
            return
        }
        // Train with input
        self.classifier.trainWithText(trainingText, category: trainingCategory)
    
        try! realm.write {
            let cData : CData = CData()
            cData.text = trainingText
            cData.category = trainingCategory
            self.realm.add(cData)
        }
        
        print("train pushed")
    }
    
    func classify(sender: UIButton) {
        // Check for input
        guard let classifyText = self.classifyTextField.text where !classifyText.isEmpty else {
            print("Missing classify text")
            return
        }
        
        let result = self.classifier.classify(classifyText)
        self.classifyResultTextField.text = result
        print("classify pushed")
    }
}
