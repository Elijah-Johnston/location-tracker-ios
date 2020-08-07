//
//  FirstViewController.swift
//  Tabbed Location Sender
//
//  Created by Eli Johnston on 2020-07-08.
//  Copyright © 2020 Eli Johnston. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pathCollectionView: UICollectionView!
    
    // MARK: - Properties
    private let reuseIdentifier = "PathCell"
    var paths : [PathMapping] = []
    let dummyPath = PathMapping(name: "dummy")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathCollectionView.delegate = self
        pathCollectionView.dataSource = self
        self.paths = dummyPath.retrieveAllPaths()!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.paths = dummyPath.retrieveAllPaths()!
        pathCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PathCollectionViewCell
        
        cell.pathLabel.text = paths[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSecondViewController(path: paths[indexPath.item])
    }
    
    func showSecondViewController(path: PathMapping) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SecondViewController") as! SecondViewController
        secondVC.path = path
        show(secondVC, sender: self)
    }
    
    @IBAction func firstViewOnClick(_ sender: Any) {
//        showSecondViewController()
        self.tabBarController?.selectedIndex = 1
    }
}
