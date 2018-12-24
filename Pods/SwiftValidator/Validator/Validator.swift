//
//  Validator.swift
//  Pingo
//
//  Created by Jeff Potter on 11/10/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol ValidationDelegate {
    func validationSuccessful()
    func validationFailed(errors: [UITextField:ValidationError])
}

public class Validator {
    // dictionary to handle complex view hierarchies like dynamic tableview cells
    public var errors = [UITextField:ValidationError]()
    public var validations = [UITextField:ValidationRule]()
    private var successStyleTransform:((_ validationRule:ValidationRule)->Void)?
    private var errorStyleTransform:((_ validationError:ValidationError)->Void)?
    
    public init(){}
    
    // MARK: Private functions
    
    private func validateAllFields() {
        
        errors = [:]
        
        for (textField, rule) in validations {
            if let error = rule.validateField() {
                errors[textField] = error
                
                // let the user transform the field if they want
                if let transform = self.errorStyleTransform {
                    transform(error)
                }
            } else {
                // No error
                // let the user transform the field if they want
                if let transform = self.successStyleTransform {
                    transform(rule)
                }
            }
        }
    }
    
    // MARK: Using Keys
    
    public func styleTransformers(success:((_ validationRule:ValidationRule)->Void)?, error:((_ validationError:ValidationError)->Void)?) {
        self.successStyleTransform = success
        self.errorStyleTransform = error
    }
    
    public func registerField(textField:UITextField, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules: rules, errorLabel: nil)
    }
    
    public func registerField(textField:UITextField, errorLabel:UILabel, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules:rules, errorLabel:errorLabel)
    }
    
    public func unregisterField(textField:UITextField) {
        validations.removeValue(forKey: textField)
        errors.removeValue(forKey: textField)
    }
    
    public func validate(delegate:ValidationDelegate) {
        
        self.validateAllFields()
        
        if errors.isEmpty {
            delegate.validationSuccessful()
        } else {
            delegate.validationFailed(errors: errors)
        }
    }
    
    public func validate(callback:(_ errors:[UITextField:ValidationError])->Void) -> Void {
        
        self.validateAllFields()
        
        callback(errors)
    }
}
