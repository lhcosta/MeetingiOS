//
//  SelectColorViewController.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class SelectColorViewController: UIViewController {

    @IBOutlet weak var viewColorSelected: UIView!
    
    var arrayColors: [UIColor] = [ UIColor(red:0.53, green:0.66, blue:0.59, alpha:1.0),
                                   UIColor(red:0.78, green:0.55, blue:0.55, alpha:1.0),
                                   UIColor(red:0.57, green:0.70, blue:0.81, alpha:1.0),
                                   UIColor(red:0.78, green:0.55, blue:0.80, alpha:1.0),
                                   UIColor(red:0.75, green:0.59, blue:0.30, alpha:1.0),
                                   UIColor(red:0.80, green:0.72, blue:0.56, alpha:1.0),
                                   UIColor(red:0.77, green:0.82, blue:0.57, alpha:1.0),
                                   UIColor(red:0.60, green:0.81, blue:0.71, alpha:1.0)]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewColorSelected.layer.cornerRadius = 20
    }
    
    

}

extension SelectColorViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrayColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colectionCell", for: indexPath)
        
        cell.backgroundColor = arrayColors[indexPath.row]
        cell.layer.cornerRadius = cell.frame.size.width/2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewColorSelected.backgroundColor = self.arrayColors[indexPath.row]
    }
    
    
}

extension SelectColorViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return collectionView.bounds.width/CGFloat(arrayColors.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return collectionView.bounds.height/CGFloat(arrayColors.count)
    }
    
}
