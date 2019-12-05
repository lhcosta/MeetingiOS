//
//  SelectColorViewController.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 04/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit

class SelectColorViewController: UIViewController {

    @IBOutlet weak var viewColorSelected: UIView!
    
    // Precisa receber a meeting a ser atualizada com a cor
    var meetingRecord = CKRecord(recordType: "Meeting")
    
    // O numero da cor selecionada
    var selectedColor: Int = 0
    
    //Array das cores a serem selecionadas
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
        
        // Arredonda a view e seta como cor inicial a primeira cor do array
        self.viewColorSelected.layer.cornerRadius = 20
        self.viewColorSelected.backgroundColor = self.arrayColors[0]
    }
    
    @IBAction func saveColor(_ sender: Any) {
        // Popula a struct com a cor selecionada
        var meeting = Meeting(record: meetingRecord)
        meeting.color = self.selectedColor
        
        // Faz o update da cor no Cloud
        CloudManager.shared.updateRecords(records: [meetingRecord], perRecordCompletion: { (record, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Meeting Updated color: ", record["color"]!)
            }
        }) {
            print("Success!")
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
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
        selectedColor = indexPath.row
    }
    
    
}

extension SelectColorViewController: UICollectionViewDelegateFlowLayout {
    
    // Seta os espaços entre as celulas
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return collectionView.bounds.width/CGFloat(arrayColors.count)
    }
    
    // Seta os espaços ente linhas
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return collectionView.bounds.height/CGFloat(arrayColors.count)
    }
    
}
