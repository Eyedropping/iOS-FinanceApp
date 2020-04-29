//
//  EntryInsertionViewController.swift
//  iOS-FinanceApp
//
//  Created by user168750 on 4/14/20.
//  Copyright © 2020 Dmitry Aksyonov. All rights reserved.
//

import UIKit
import RealmSwift

protocol EntryInsertionDelegate {
    func dataDidSendOnInsertion(_ data: Int)
}

class EntryInsertionViewController: UIViewController{
    // MARK: - Realm
    var realm = try! Realm()
    let allEntries = try! Realm().objects(Entry.self)
    
    
    // MARK: - Outlets
    @IBOutlet weak var imageForCategory: UIImageView!
    @IBOutlet weak var nameInputTextField: UITextField!
    @IBOutlet weak var amntInputTextField: UITextField!
    @IBOutlet weak var dateInputTextField: UITextField!
    @IBOutlet weak var categoryInputTextField: UITextField!
    @IBOutlet weak var isExpenseTextField: UITextField!
    
    // MARK: - Programmatic Properties
    var datePicker = UIDatePicker()
    let categoryPicker = UIPickerView() // needed for categories picking
    var toolBar = UIToolbar()
    var delegate: EntryInsertionDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageForCategory.layer.cornerRadius = imageForCategory.frame.size.width / 2
        imageForCategory.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        createDatePicker()
        createToolbar()
        dateInputTextField.inputView = datePicker
        dateInputTextField.inputAccessoryView = toolBar
    }
    
    // MARK: - Add Entry Logic
    @IBAction func addEntryButton(_ sender: UIButton) {
        let validator = TextValidation()
        
        if validator.inputIsValidated(input: nameInputTextField.text!, pattern: validator.regExes["alphaNumericRegEx"]!) == true &&
            validator.inputIsValidated(input: amntInputTextField.text!, pattern: validator.regExes["numericRegEx"]!) == true &&
            isExpenseTextField.text == "Expense" || isExpenseTextField.text == "Income" {
            
            let entry = Entry(name: nameInputTextField.text!, amount: Int(amntInputTextField.text!)!, date: createDateFormatter(dateStyle: .short, timeStyle: .none).date(from: dateInputTextField.text!)!, category: categoryInputTextField.text!, entryType: isExpenseTextField.text!)
            
            if isExpenseTextField.text! == "Expense" {
                entry.amount *= -1
                delegate?.dataDidSendOnInsertion(entry.amount)
                writeToRealm(write: entry) // DRY 1
                self.dismiss(animated: true, completion: nil) // DRY 2
            } else {
                delegate?.dataDidSendOnInsertion(entry.amount)
                writeToRealm(write: entry) // DRY 1
                self.dismiss(animated: true, completion: nil) // DRY 2
            }
        } else {
            let alert = UIAlertController(title: "invalid input", message: "some of the patterns did not match the input", preferredStyle: .alert)
            self.present(alert, animated: true, completion:  {
                alert.dismissOnTapOutside()
            })
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil) // DRY 2
    }
    
    // MARK: - Date Picker and Toolbar Stuff
    func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(for:)), for: .valueChanged)
    }
    
    func createToolbar() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let todayButton = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayButtonPressed(sender :)))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width / 5, height: 40))
        let labelButton = UIBarButtonItem(customView: label)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        label.text = "Pick a date"
        
        toolBar.setItems([todayButton, flexibleSpace, labelButton, flexibleSpace, doneButton], animated: true)
    }
    
    // MARK: - Date Formatter Stuff
    func createDateFormatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter
    }
}

// MARK: - Keyboard Dismiss
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Text Field Return Key Switch
extension EntryInsertionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            amntInputTextField.becomeFirstResponder()
        }
        return false
    }
}

// MARK: - Date Picker Controls and Helpers
extension EntryInsertionViewController {
    @objc func datePickerValueChanged(for datePicker: UIDatePicker) {
        dateInputTextField.text = createDateFormatter(dateStyle: .medium, timeStyle: .none).string(from: datePicker.date)
    }
    
    @objc func todayButtonPressed(sender: UIBarButtonItem) {
        dateInputTextField.text = createDateFormatter(dateStyle: .medium, timeStyle: .none).string(from: Date())
        dateInputTextField.resignFirstResponder()
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        dateInputTextField.resignFirstResponder()
    }
    
    func booleanHelper(input: String) -> Bool {
        if input == "Expense" {
            return true
        } else {
            return false
        }
    }
    
    private func writeToRealm(write item: Entry) {
        realm.beginWrite()
        realm.add(item)
        try! realm.commitWrite()
    }
}