//
//  ConclusionInfoTableViewCell.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionInfoTableViewManager: NSObject {
    
    /// Quando viemos de uma Meeting não finalizada.
    var fromUnfinishedMeeting = false
    var meetingDidBegin = true
    
    /// Table View de conclusões
    weak var conclusionTableView : UITableView!
    weak var viewControler: ConclusionsViewController!
    
}

extension ConclusionInfoTableViewManager: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !fromUnfinishedMeeting || meetingDidBegin {
            return viewControler.topicToPresentConclusions.conclusions.count
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conCell", for: indexPath) as! ConclusionTableViewCell
        
        if !fromUnfinishedMeeting || meetingDidBegin {
            cell.textConclusion.text = viewControler.topicToPresentConclusions.conclusions[indexPath.row]
        } else {
            cell.textConclusion.isUserInteractionEnabled = false
            cell.textConclusion.text = "Disponível depois que a Reunião começar."
        }
        
        cell.textConclusion.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Caso seja a ultima conclusão - Teoricamente ela estaria em branco para indicar que está habilitadad a edição, esta não poderá ser excluída
        if indexPath.row != self.viewControler.topicToPresentConclusions.conclusions.count-1 {
            
            // Exclui a celula selecionada e atualiza a tableView
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                print("Index Pathhhh: \(indexPath.row)")
                self.viewControler.topicToPresentConclusions.conclusions.remove(at: indexPath.row)
                self.conclusionTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension ConclusionInfoTableViewManager: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewControler.activeField = textField
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Obtem a referência da calular para a obtenção do indexPath referente
        if !(textField.text?.isEmpty ?? true){
            let index = self.viewControler.topicToPresentConclusions.conclusions.count-1
            self.viewControler.topicToPresentConclusions.conclusions.insert(textField.text!, at: index)
            self.conclusionTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.conclusionTableView.scrollToRow(at: IndexPath(row: index+1, section: 0), at: .bottom, animated: .random())
            textField.text = ""
            viewControler.isChangedTopic = true
        }
        
        return true
    }
}
