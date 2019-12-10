//
//  FinishedReunionViewController.swift
//  MeetingiOS
//
//  Created by Paulo Ricardo on 11/29/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CloudKit


/// Essa View será exibida após a seleção de uma Meeting que já foi encerrada.
class FinishedMeetingViewController: UIViewController {
    
    /// Segmented usado para visualizar os Topics discutidos e não discutidos.
    @IBOutlet var topicsSegmentedControl: UISegmentedControl!
    
    /// TableView com as Topics da Meeting.
    @IBOutlet var topicsTableView: UITableView!
    
    /// Topics da Meeting que serão exibidos (sendo passados como Topic não Reference)
    var topics: [Topic] = []
    /// Topics marcados como não discutidos (será inicializado na call da função organizeTopics)
    var undiscussedTopics: [Topic] = []
    /// Topics marcados como discutidos (será inicializado na call da função organizeTopics)
    var discussedTopics: [Topic] = []
    /// Topic selecionado na tableView, será mandado para a ConclusionsViewController que exibirá suas conclusions.
    var currSelectedTopic: Topic?
    /// Meeting criada pelo usuário.
    var currMeeting: Meeting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicsTableView.delegate = self
        topicsTableView.dataSource = self
        
        // MARK: SIMULAÇÃO
        for i in 0...14 {
            topics.append(createTopic("Description \(i)", author: "Author \(i)"))
        }
        for i in 0...3 {
            topics.append(createUndiscussedTopic("Description \(i)", author: "Author \(i)"))
        }
        
        organizeTopics()
    }
    
    
    /// Atualizamos a tableView de quando alteramos o SegmentedControl
    /// - Parameter sender: Default.
    @IBAction func segmentedAction(_ sender: Any) {
        
        topicsTableView.reloadData()
    }
    
    
    /// Separamos os Topics recebidos em se eles foram Discutidos ou não (através do atributo discussed: Bool).
    func organizeTopics() {
        for i in self.topics {
            if i.discussed {
                self.discussedTopics.append(i)
            } else {
                self.undiscussedTopics.append(i)
            }
        }
    }
    
    
    /// Identificamos a passagem dessa ViewController para a ConclusionViewController e passamos o Topic selecionado na TableView
    ///  para então exibirmos suas Conclusions na ConclusionsViewController.
    /// - Parameters:
    ///   - segue: Default
    ///   - sender: Default
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "conclusions" {
            let vc = segue.destination as! ConclusionsViewController
            vc.topicToPresentConclusions = currSelectedTopic
        }
    }
    
    
    /// Método de testes para criar Topics discutidos.
    /// - Parameters:
    ///   - description: Título do Topic.
    ///   - author: Nome do author do Topic.
    func createTopic(_ description: String, author: String) -> Topic {
        
        let record = CKRecord(recordType: "Topic")
        let newTopic = Topic(record: record)
        newTopic.editDescription(description)
        newTopic.authorName = author
        newTopic.discussed = true
        
        return newTopic
    }
    
    
    /// Método de testes para criar Topics não discutidos.
    /// - Parameters:
    ///   - description: Título do Topic.
    ///   - author: Nome do author do Topic.
    func createUndiscussedTopic(_ description: String, author: String) -> Topic {
        
        let record = CKRecord(recordType: "Topic")
        let newTopic = Topic(record: record)
        newTopic.editDescription("\(description) (undiscussed)")
        newTopic.authorName = author
        
        return newTopic
    }
    
    
    /// Método de testes para a criação de Conclusions do Topic
    /// - Parameter qtd: Quantidade de Conclusions.
    func createConclusions(qtd: Int) -> [String] {
        var conclusions: [String] = []
        for i in 0...qtd {
            conclusions.append("Conclusion\nNumber\n\(i)")
        }
        return conclusions
    }
}


extension FinishedMeetingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if topicsSegmentedControl.selectedSegmentIndex == 0 {
            return self.discussedTopics.count
        }
        return self.undiscussedTopics.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FinishedTopicsTableViewCell
        if topicsSegmentedControl.selectedSegmentIndex == 0 {
            cell.topicDescriptionLabel.text = discussedTopics[indexPath.row].topicDescription
            cell.authorNameLabel.text = discussedTopics[indexPath.row].authorName
        } else {
            cell.topicDescriptionLabel.text = undiscussedTopics[indexPath.row].topicDescription
            cell.authorNameLabel.text = undiscussedTopics[indexPath.row].authorName
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if topicsSegmentedControl.selectedSegmentIndex == 0 {
            self.currSelectedTopic = discussedTopics[indexPath.row]
        } else {
            self.currSelectedTopic = undiscussedTopics[indexPath.row]
        }
        currSelectedTopic?.conclusions = createConclusions(qtd: 9)
        performSegue(withIdentifier: "conclusions", sender: self)
    }
}
