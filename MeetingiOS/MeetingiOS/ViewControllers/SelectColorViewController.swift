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
    var selectedColor = String()
    
    //Array do hex das cores a serem selecionadas
    var arrayColors: [String] = [ "#88A896",
                                   "#C68C8D",
                                   "#92B3CE",
                                   "#C68ECB",
                                   "#BE9553",
                                   "#CBB791",
                                   "#C4D094",
                                   "#9BCEB6"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Arredonda a view e seta como cor inicial a primeira cor do array
        self.viewColorSelected.layer.cornerRadius = 20
        self.viewColorSelected.backgroundColor = UIColor(named: self.arrayColors[0])
    }
    
    @IBAction func saveColor(_ sender: Any) {
        // Mandar a String da cor para a tela de criação da Reunião
    }

}

extension SelectColorViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrayColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colectionCell", for: indexPath)
        
        // Adiciona a cor a celula da collection de acordo com o array de cores
        cell.backgroundColor = UIColor(named: self.arrayColors[indexPath.row])
        cell.layer.cornerRadius = cell.frame.size.width/2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewColorSelected.backgroundColor = UIColor(named: self.arrayColors[indexPath.row])
        selectedColor = self.arrayColors[indexPath.row]
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
