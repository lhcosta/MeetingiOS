//
//  DatePickersSetup.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 21/01/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

/// Protocolo para implementar date pickers de data com ínicio e fim.
@objc protocol DatePickersSetup {
    
    /// Configurações iniciais.
    /// - Parameters:
    ///   - startDatePicker: date picker inicial.
    ///   - finishDatePicker: date picker final.
    @objc func setupPickers(startDatePicker: UIDatePicker, finishDatePicker: UIDatePicker)
    
    /// Alteração na data de início.
    /// - Parameter datePicker: data inicial.
    @objc func modifieStartDateTime(datePicker : UIDatePicker)
    
    /// Alteração no horário final.
    /// - Parameter datePicker: data final.
    @objc func modifieEndTime(datePicker : UIDatePicker)
}

