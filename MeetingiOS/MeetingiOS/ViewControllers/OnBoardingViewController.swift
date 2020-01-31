//
//  OnBoardingViewController.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 12/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    @IBOutlet private weak var tableView : UITableView!
    
    //MARK:- Properties
    private let images = [UIImage(named: "onboarding_1"),
                          UIImage(named: "onboarding_2"),
                          UIImage(named: "onboarding_3"),
                          UIImage(named: "onboarding_4")]
    private var texts = [["Create meetings", "Create meetings and share with your coworkers"],
                         ["Connect with your team", "Be aware of what your coworkers want to talk"],
                         ["Time your meetings", "Increase the productivity of your meetings"], 
                         ["Increase the dynamics", "Have easy access to your meeting feedbacks"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "OnboardingTableViewCell", bundle: nil), forCellReuseIdentifier: "OnboardingCell")
        
        self.texts = self.texts.map { (texts) -> [String] in
            texts.map { (text) -> String in
                NSLocalizedString(text, comment: "")
            }
        }
        
        self.view.backgroundColor = UIColor(named: "OnboardingColor")
    }
}

//MARK:- UITableViewDataSource
extension OnBoardingViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "WelcomeCell", for: indexPath) as! WelcomeOnboardingTableViewCell
            case 5:
                return tableView.dequeueReusableCell(withIdentifier: "ContinueCell", for: indexPath) as! ContinueOnboardingTableViewCell
            
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OnboardingCell", for: indexPath) as! OnboardingTableViewCell
                let index = indexPath.section - 1
                cell.title.text = self.texts[index][0]
                cell.descriptionText.text = self.texts[index][1]
                cell.imageDescription.image = self.images[index]
                return cell
        }
    }    
}

//MARK:- UITableViewDelegate
extension OnBoardingViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //Utilizado um tamanho base e criamos o layout, depois adaptamos de acordo com o aumento
        //ou diminuicao da altura de forma proporcional
        
        var height = CGFloat()
        let height_base : CGFloat = 812        
        let differenceHeights = abs((height_base - self.tableView.frame.height))
        let differencePercent = ((differenceHeights * 100)/height_base)/100
        let bigger = self.tableView.frame.height > height_base
        
        switch section {
            case 0:
                height = 80
            case 1:
                height = 50
            case 2,3,4:
                height = 45
            case 5:
                height = 80
            default:
            break
        }
        
        let size = bigger ? height + (height * differencePercent) : height - (height * differencePercent)
        
        return size.rounded()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = CGFloat()
   
        switch indexPath.section {
            case 0:
                height = self.tableView.frame.height * 0.12
            case 1,2,3,4:
                height = self.tableView.frame.height * 0.08
            case 5:
                height = 45
            default:
            break
        }
        
        return height
    }
}



