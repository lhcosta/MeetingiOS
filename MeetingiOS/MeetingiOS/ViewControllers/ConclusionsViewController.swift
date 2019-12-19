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
    
    
    @IBOutlet weak var tableViewInfo: UITableView!
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var topicTimeLabel: UILabel!
    
//    @IBOutlet var conclusionsTableView: UITableView!
    
    // Conclusions vindos do Tópico Seelecionado
    var topicToPresentConclusions: Topic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuração da Navigation - Título e ação do botão Done
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        navigationItem.title = "Details"
        
        // Configruração da TableView
//        conclusionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewInfo.delegate = self
        tableViewInfo.dataSource = self
        
        // Arredondando bordas da View
        viewTopic.layer.cornerRadius = 3
        viewAuthor.layer.cornerRadius = 3
        viewTimer.layer.cornerRadius = 3
        
        setShadow(view: viewTopic)
        setShadow(view: viewAuthor)
        setShadow(view: viewTimer)
        
        setShadow(view: tableViewInfo)
        
        tableViewInfo.layer.cornerRadius = 3
        
        //Reconhece o gesto e o adiciona na tela
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        // Dispara as funções de manipulação do teclado
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setShadow (view: UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset  = CGSize(width: 0.0, height: 3.0)
        view.layer.shadowRadius = 3
    }
    
    // Ação do botão Done para mandar a conclusiona para o Cloud
    @objc func doneAction() {
        print("Done")
        
        CloudManager.shared.updateRecords(records: [topicToPresentConclusions.record], perRecordCompletion: { (record, error) in
            if let error = error {
                print("Error Cloud: \(error)")
            } else {
                print("Conclusion Successifuly added!")
                
                DispatchQueue.main.async {
                    self.navigationController!.popViewController(animated: true)
                    
                }
            }
        }) {
            print("Done Request")
        }
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDescription", for: indexPath) as! DescriptionTableViewCell
            
            setShadow(view: cell.descriptionView)
            cell.descriptionLabel.text = " dsfgck"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellConclusion", for: indexPath) as! ConclusionInfoTableViewCell
            cell.viewControler = self
            cell.conclusionTableView.delegate = cell
            cell.conclusionTableView.dataSource = cell
            
            return cell
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Caso seja a ultima conclusão - Teoricamente ela estaria em branco para indicar que está habilitadad a edição, esta não poderá ser excluída
        if indexPath.row != self.topicToPresentConclusions.conclusions.count-1 {
            
            // Exclui a celula selecionada e atualiza a tableView
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
                print("Index Pathhhh: \(indexPath.row)")
                self.topicToPresentConclusions.conclusions.remove(at: indexPath.row)
//                self.conclusionsTableView.reloadData()
            }
        }
    }
}
