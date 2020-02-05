//
//  DetailsTableViewController.h
//  MeetingiOS
//
//  Created by Lucas Costa  on 14/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "Contact.h"
#import "MeetingDelegate.h"
#import "ContactCollectionView.h"

@class Meeting;
@class DetailsNewMeetingManager;

NS_ASSUME_NONNULL_BEGIN

@interface DetailsTableViewController : UITableViewController

//MARK:- IBOutlets

/// Nome de reunião.
@property (weak, nonatomic) IBOutlet UITextField *meetingName;

/// Nome do criador da reunião.
@property (weak, nonatomic) IBOutlet UILabel *meetingAdmin;

/// Data inicial da reunião.
@property (weak, nonatomic) IBOutlet UILabel *startsDate;

/// Data final da reunião
@property (weak, nonatomic) IBOutlet UILabel *endesDate;

/// Número de participantes.
@property (weak, nonatomic) IBOutlet UILabel *numbersOfPeople;

/// Tópicos possíveis por pessoa.
@property (weak, nonatomic) IBOutlet UILabel *topicsPerPerson;

/// Participantes da reunião.
@property (weak, nonatomic) IBOutlet UICollectionView *collectionParticipants;

/// Modificar nome da reunião.
@property (weak, nonatomic) IBOutlet UIButton *modifyName;

/// Escolher nova data de início.
@property (nonatomic, weak) IBOutlet UIDatePicker* startDatePicker;

/// Escolher nova data de fim.
@property (nonatomic, weak) IBOutlet UIDatePicker* finishDatePicker;

/// Views que contém as características da reunião.
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *views;

/// Escolher a quantidade de tópicos.
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

/// Content View criar para alterar o layout da collection de participantes.
@property (nonatomic, weak) IBOutlet UIView* contentViewCollection;

/// Confirmar a atualização da reunião.
@property (nonatomic, weak) IBOutlet UIBarButtonItem* updateMeeting;

/// Contatos selecionados.
@property (nonatomic) ContactCollectionView* contactCollectionView;

/// Reunião
@property (nonatomic) Meeting* meeting;

/// Usuários da reunião que possuem record.
@property (nonatomic) NSMutableArray<User*> *employees_user;

/// Formato da data.
@property (nonatomic, nonnull) NSDateFormatter* formatter;

/// Gerenciador de alguns métodos da view controller.
@property (nonatomic) DetailsNewMeetingManager* detailsManagerController;

/// Monitorando se a reunião foi modificada.
@property (nonatomic) BOOL isMeetingModified;

//MARK:- Methods

/// Alterando o nome da reunião.
/// @param sender botão clicado.
-(IBAction)changeMeetingName:(id)sender;

@end

NS_ASSUME_NONNULL_END
