//
//  DataValidation.swift
//  iOS-FinanceApp
//
//  Created by user168750 on 4/29/20.
//  Copyright © 2020 Dmitry Aksyonov. All rights reserved.
//

import Foundation

class TextValidation {
    
    let regExes: [String : String] = [
        "alphaNumericRegEx" : "[A-Z0-9a-z .,]{2,70}",
        "numericRegEx" : "\\d+",
        "dateRegEx" : "[A-Z]?[a-z]{2} [0-9]{2}, [0-9]{4}",
        "pwdRegEx" : "([1-zA-Z0-1@.\\S\\s]{1,255})"
    ]
    
    public func inputIsValidated(input text: String, pattern regEx: String) -> Bool {
        if text == "" { return false } else {
            return createPredicate(pattern: regEx).evaluate(with: whitespacesDidTrim(input: text))
        }
    }
    
    private func whitespacesDidTrim(input: String) -> String {
        if input.doesContainWhitespacesAndNewLines == true {
            return input.filter { !$0.isNewline && !$0.isWhitespace }
        } else {
            return input
        }
    }
    
    private func createPredicate(pattern regEx: String) -> NSPredicate {
        return NSPredicate(format: "SELF MATCHES %@", regEx)
    }
}

extension String {
    var doesContainWhitespacesAndNewLines: Bool {
        return (self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}

