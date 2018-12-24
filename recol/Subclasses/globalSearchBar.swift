//
//  globalSearchBar.swift
//  Folio
//
//  Created by Farhad Saadatpei on 4/27/18.
//  Copyright © 2018 Xrait. All rights reserved.
//

import UIKit

class globalSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        setShowsCancelButton(false, animated: false)
    }
}

class globalSearchController: UISearchController, UISearchBarDelegate {
    
    lazy var _searchBar: globalSearchBar = {
        [unowned self] in
        let result = globalSearchBar(frame: CGRect(origin: .zero, size: .zero))
        result.delegate = self
        
        return result
        }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}

extension UISearchBar {
    
    func insideTextStyle(font: UIFont) {
        let insideSearchBarTextField = self.value(forKey: "searchField") as? UITextField
        insideSearchBarTextField?.textColor = UIColor.black
        insideSearchBarTextField?.font = font
        
        let insideSearchBarTextFieldLabel = insideSearchBarTextField?.value(forKey: "placeholderLabel") as? UILabel
        insideSearchBarTextFieldLabel?.textColor = UIColor.init(white: 0, alpha: 0.30)
        insideSearchBarTextFieldLabel?.font = font
    }
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
}

