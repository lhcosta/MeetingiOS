//
//  NewMeetingViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 02/12/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "MeetingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// View Controller para criar uma nova reuniao
@interface NewMeetingViewController : UITableViewController<MeetingDelegate>

//MARK:- IBOutlets

/// Data de início.
@property (nonatomic, weak) IBOutlet UILabel* startsDateTime;

/// Data de término.
@property (nonatomic, weak) IBOutlet UILabel* endesDateTime;

/// Collection View dos contatos
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;

/// Nome da reunião.
@property (nonatomic, weak) IBOutlet UITextField* nameMetting;

/// Cor da reunião.
@property (nonatomic, weak) IBOutlet UIButton* colorMetting;

/// Quantidade de tópicos.
@property (nonatomic, weak) IBOutlet UILabel* numbersOfTopics;

/// Quantidade de participantes.
@property (nonatomic, weak) IBOutlet UILabel* numbersOfPeople;

/// Picker view do número de tópicos.
@property (nonatomic, weak) IBOutlet UIPickerView* pickerView;

/// Date Picker da data inicial.
@property (nonatomic, weak) IBOutlet UIDatePicker* startDatePicker;

/// Date Picker da data final.
@property (nonatomic, weak) IBOutlet UIDatePicker* finishDatePicker;

/// Views com as características da reunião.
@property (nonatomic) IBOutletCollection(UIView) NSArray *views;

/// Content view da collection para modificar layout.
@property (nonatomic, weak) IBOutlet UIView* contentViewCollection;

//MARK:- Methods
///Selecionando a cor do ícone da reunião.
- (IBAction) chooseColorMeeting:(id)sender;

@end

NS_ASSUME_NONNULL_END
