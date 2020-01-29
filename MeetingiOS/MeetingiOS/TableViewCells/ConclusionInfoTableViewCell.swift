//
//  ConclusionInfoTableViewCell.swift
//  MeetingiOS
//
//  Created by Caio Azevedo on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var conclusionTableView: UITableView!
    
    /// Quando viemos de uma Meeting não finalizada.
    var fromUnfinishedMeeting = false
    var meetingDidBegin = true
    
    var viewControler: ConclusionsViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ConclusionInfoTableViewCell: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !fromUnfinishedMeeting || meetingDidBegin {
            
            if viewControler.topicToPresentConclusions.conclusions.count == 0 {
                viewControler.topicToPresentConclusions.conclusions.append("")
                return 1
            } else {
                return viewControler.topicToPresentConclusions.conclusions.count
            }
        } else {
            return 1
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conCell", for: indexPath) as! ConclusionTableViewCell

        if !fromUnfinishedMeeting || meetingDidBegin {
            cell.textConclusion.text = viewControler.topicToPresentConclusions.conclusions[indexPath.row]
        } else {
            cell.textConclusionLabel.isHidden = false
            cell.textConclusion.isHidden = true
            cell.textConclusionLabel.text = "Disponível depois que a Reunião começar."
        }
        cell.textConclusion.delegate = self

        return cell
    }


//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.viewControler.tableViewInfo.frame.height
//    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Caso seja a ultima conclusão - Teoricamente ela estaria em branco para indicar que está habilitadad a edição, esta não poderá ser excluída
        if indexPath.row != self.viewControler.topicToPresentConclusions.conclusions.count-1 {

            // Exclui a celula selecionada e atualiza a tableView
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                print("Index Pathhhh: \(indexPath.row)")
                self.viewControler.topicToPresentConclusions.conclusions.remove(at: indexPath.row)
                self.conclusionTableView.reloadData()
            }
        }
    }
}

extension ConclusionInfoTableViewCell: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {

        // Obtem a referência da calular para a obtenção do indexPath referente
        guard let cell = textField.superview?.superview as? ConclusionTableViewCell else { return }
        let indexPath = conclusionTableView.indexPath(for: cell)

        // Se o tópico estiva em branco então após a edição do mesmo adiciona um topico em branco abaixo para futura edição
        if self.viewControler.topicToPresentConclusions.conclusions[indexPath!.row] == "" {
            self.viewControler.topicToPresentConclusions.conclusions[indexPath!.row] = textField.text!
            self.viewControler.topicToPresentConclusions.conclusions.append(String())
        } else {
            self.viewControler.topicToPresentConclusions.conclusions[indexPath!.row] = textField.text!
        }

        // Atualiza os dados da tableView
        self.conclusionTableView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
