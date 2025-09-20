//
//  ContactPickerView.swift
//  LupusInFabula
//
//  Created by AI on 30/08/25.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CNContactPickerViewController
    
    var onSelect: (_ fullName: String, _ phoneNumber: String) -> Void
    var onCancel: (() -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onCancel: onCancel)
    }
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        // no-op
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (_ fullName: String, _ phoneNumber: String) -> Void
        let onCancel: (() -> Void)?
        
        init(onSelect: @escaping (_: String, _: String) -> Void, onCancel: (() -> Void)?) {
            self.onSelect = onSelect
            self.onCancel = onCancel
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel?()
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
            if let firstPhone = contact.phoneNumbers.first?.value.stringValue {
                onSelect(name, firstPhone)
            } else {
                onSelect(name, "")
            }
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            let name = CNContactFormatter.string(from: contactProperty.contact, style: .fullName) ?? ""
            var phone = ""
            if let phoneValue = contactProperty.value as? CNPhoneNumber {
                phone = phoneValue.stringValue
            }
            onSelect(name, phone)
        }
    }
}


