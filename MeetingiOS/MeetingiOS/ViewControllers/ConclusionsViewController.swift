//
//  ConclusionsViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class ConclusionsViewController: UIViewController {
    
    @IBOutlet weak var viewTopic: UIView!
    @IBOutlet weak var viewAuthor: UIView!
    @IBOutlet weak var viewTimer: UIView!
    
    
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var topicTimeLabel: UILabel!
    @IBOutlet var conclusionsTableView: UITableView!
    
    // Conclusions vindos do Tópico Seelecionado
    var topicToPresentConclusions: Topic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuração da Navigation - Título e ação do botão Done
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        navigationItem.title = "Details"
        
        // Configruração da TableView
//        conclusionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        conclusionsTableView.delegate = self
        conclusionsTableView.dataSource = self
        
        // Arredondando bordas da View
        viewTopic.layer.cornerRadius = 10
        viewAuthor.layer.cornerRadius = 10
        viewTimer.layer.cornerRadius = 10
        
        //Reconhece o gesto e o adiciona na tela
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        // Dispara as funções de manipulação do teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Ação do botão Done para mandar a conclusiona para o Cloud
    @objc func doneAction() {
        print("Done")
    }
    
    // Remove o teclado da tela
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Eleva a tela para o teclado aparecer
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    // Volta a tela para o normal sem o teclado
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}


extension ConclusionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicToPresentConclusions.conclusions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conCell", for: indexPath) as! ConclusionTableViewCell
        
        cell.textConclusion.text = topicToPresentConclusions.conclusions[indexPath.row]
        cell.textConclusion.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Conclusion"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Caso seja a ultima conclusão - Teoricamente ela estaria em branco para indicar que está habilitadad a edição, esta não poderá ser excluída
        if indexPath.row != self.topicToPresentConclusions.conclusions.count-1 {
            
            // Exclui a celula selecionada e atualiza a tableView
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                print("Index Pathhhh: \(indexPath.row)")
                self.topicToPresentConclusions.conclusions.remove(at: indexPath.row)
                self.conclusionsTableView.reloadData()
            }
        }
    }
}

extension ConclusionsViewController: UITextFieldDelegate{
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Obtem a referência da calular para a obtenção do indexPath referente
        guard let cell = textField.superview?.superview as? ConclusionTableViewCell else { return }
        let indexPath = conclusionsTableView.indexPath(for: cell)
        
        // Se o tópico estiva em branco então após a edição do mesmo adiciona um topico em branco abaixo para futura edição
        if self.topicToPresentConclusions.conclusions[indexPath!.row] == ""{
            self.topicToPresentConclusions.conclusions[indexPath!.row] = textField.text!
            self.topicToPresentConclusions.conclusions.append(String())
        } else {
            self.topicToPresentConclusions.conclusions[indexPath!.row] = textField.text!
        }
        
        // Atualiza os dados da tableView
        self.conclusionsTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
