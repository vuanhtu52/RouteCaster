//
//  ErrorHandle.swift
//  Final1
//
//  Created by Misaa Pandaaa on 4/25/19.
//  Copyright © 2019 Huynh Nguyen Nguyen. All rights reserved.
//

import Foundation
import Firebase

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use"
        case .invalidEmail:
            return "Your email is invalid"
        case .wrongPassword:
            return "Your password is wrong"
        case .weakPassword:
            return "Your password is too weak. It must be 6 characters long or more"
        case .networkError:
            return "Network error. Please try again"
        case .userNotFound:
            return "Account can be not found"
        case .requiresRecentLogin:
            return "Please log out and sign in again to update email."
        default:
            return "Unknown error occurred"
        }
    }
}

extension UIViewController {
    func handleError (_ error: Error) {
        if let errorCode = AuthErrorCode (rawValue: error._code) {
            print(errorCode.errorMessage)
            let alert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
        }
    }
    
}
    
    


