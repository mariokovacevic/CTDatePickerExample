//
//  DatePicker.swift
//
//
//  Created by Mario Kovacevic on 18/09/2018.
//  Copyright © 2018 Comtrade. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class DatePicker: UIAlertController {
    
    static fileprivate let datePickerHeight: CGFloat = 120
    static fileprivate let alertViewControllerHeaderHeight: CGFloat = 60
    static fileprivate let buttonHeight: CGFloat = 60
    
    public typealias SetBlock = ((_ date: Date)->())
    public typealias CancelBlock = (() -> Void)
    
    public var didSet: SetBlock?
    public var didCancel: CancelBlock?
    
    fileprivate let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = .clear
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.heightAnchor.constraint(equalToConstant: DatePicker.datePickerHeight).isActive = true
        return datePicker
    }()
    
    fileprivate let timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = .clear
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.heightAnchor.constraint(equalToConstant: DatePicker.datePickerHeight).isActive = true
        return datePicker
    }()
    
    fileprivate let setButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(red: 9/255.0, green: 90/255.0, blue: 250/255.0, alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: DatePicker.buttonHeight).isActive = true
        button.addTarget(self, action: #selector(setAction), for: .touchUpInside)
        return button
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(red: 250/255.0, green: 29/255.0, blue: 28/255.0, alpha: 1.0), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: DatePicker.buttonHeight).isActive = true
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        return button
    }()
    
    fileprivate var containerStack: UIStackView!
    fileprivate var datePickersStack: UIStackView!
    fileprivate var buttonsStack: UIStackView!
    
    fileprivate var useDateAndTime: Bool = false
    
    public convenience init(
        datePickerMode: UIDatePicker.Mode = .date,
        currentDate: Date? = nil,
        maximumDate: Date? = nil,
        minimumDate: Date? = nil,
        onSet: SetBlock? = nil,
        onCancel: CancelBlock? = nil) {
        
        self.init(title: DatePicker.controllerTitle(datePickerMode: datePickerMode), message: "", preferredStyle: .actionSheet)
        self.didSet = onSet
        self.didCancel = onCancel
        self.useDateAndTime = datePickerMode == .dateAndTime
        
        self.datePicker.datePickerMode = datePickerMode
        self.datePicker.maximumDate = maximumDate
        self.datePicker.minimumDate = minimumDate
        self.datePicker.setDate(currentDate ?? Date(), animated: true)
        
        if self.useDateAndTime {
            self.datePicker.datePickerMode = .date
            self.timePicker.datePickerMode = .time
            self.timePicker.maximumDate = maximumDate
            self.timePicker.minimumDate = minimumDate
            self.timePicker.setDate(currentDate ?? Date(), animated: true)
        }
        
        self.initialiseDatePickerStack()
        self.initialiseButtonStack()
        self.initialiseContainerStack()
        
        self.view.addSubview(self.containerStack)
        
        self.setupConstraints()
    }
    
    fileprivate func initialiseContainerStack() {
        self.containerStack = UIStackView(arrangedSubviews: [self.datePickersStack, self.buttonsStack])
        self.containerStack.alignment = .fill
        self.containerStack.axis = .vertical
        self.containerStack.distribution = .fillProportionally
    }
    
    fileprivate func initialiseDatePickerStack() {
        self.datePickersStack = UIStackView(arrangedSubviews: [self.datePicker, self.timePicker])
        self.datePickersStack.alignment = .fill
        self.datePickersStack.axis = .vertical
        self.datePickersStack.distribution = .fillEqually
    }
    
    fileprivate func initialiseButtonStack() {
        let border = UIView()
        border.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5)
        border.backgroundColor = UIColor.lightGray
        border.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let border2 = UIView()
        border2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5)
        border2.backgroundColor = UIColor.lightGray
        border2.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        self.buttonsStack = UIStackView(arrangedSubviews: [border, self.setButton, border2, self.cancelButton])
        self.buttonsStack.alignment = .fill
        self.buttonsStack.axis = .vertical
        self.buttonsStack.distribution = .fillProportionally
    }
    
    @objc func setAction() {
        let dateTime = self.combineDateWithTime(date: self.datePicker.date, time: self.timePicker.date)
        self.didSet?(self.useDateAndTime ? dateTime : self.datePicker.date)
        self.dismiss(animated: true)
    }
    
    @objc func dismissAction() {
        self.didCancel?()
        self.dismiss(animated: true)
    }
    
    fileprivate func setupConstraints() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerStack.translatesAutoresizingMaskIntoConstraints = false
        self.containerStack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: DatePicker.alertViewControllerHeaderHeight).isActive = true
        self.containerStack.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.containerStack.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.containerStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.timePicker.isHidden = !self.useDateAndTime
    }
    
    fileprivate func combineDateWithTime(date: Date, time: Date) -> Date {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        mergedComponments.second = timeComponents.second
        
        return calendar.date(from: mergedComponments) ?? Date()
    }
    
    fileprivate static func controllerTitle(datePickerMode: UIDatePicker.Mode) -> String {
        var title = "Select Date and Time:"
        switch datePickerMode {
        case .date:
            title = "Select Date"
        case .countDownTimer:
            title = "Select Hour and Minutes"
        case .time:
            title = "Select Time"
        case .dateAndTime:
            title = "Select Date and Time:"
        @unknown default:
            fatalError()
        }
        return title
    }
}
