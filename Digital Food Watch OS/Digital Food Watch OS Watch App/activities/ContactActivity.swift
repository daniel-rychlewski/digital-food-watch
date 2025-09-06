import SwiftUI
import Foundation
import Combine
import WatchKit
import Contacts

struct ContactActivity : View {
    static let nameRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                    ) ["main"] as? [String: Any] ?? [:]
                                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                    ) ["nameRegex"] as? [String: Any] ?? [:]
                                                                    ) ["stringValue"] as? String ?? "^[^0-9]+$", options: [])
    static let emailRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                     ) ["main"] as? [String: Any] ?? [:]
                                                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                     ) ["emailRegex"] as? [String: Any] ?? [:]
                                                                     ) ["stringValue"] as? String ?? "^[A-Za-z0-9._&%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}$", options: [])
    static let phoneNumberRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["phoneNumberRegex"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String ?? "^[+]?[0-9]+$", options: [])
    static let streetRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["streetRegex"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String ?? "^(?!$).+", options: [])
    static let zipRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["zipRegex"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String ?? "^(?!$).+", options: [])
    static let cityRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["cityRegex"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String ?? "^(?!$).+", options: [])
    static let instructionsRegex = try! NSRegularExpression(pattern: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["instructionsRegex"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String ?? "(?s).+", options: [])
    
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isEmailFieldFocused: Bool
    @FocusState private var isPhoneNumberFieldFocused: Bool
    
    @State private var showingNoImportContactFoundAlert = false
    @State private var showingAccessContactsError = false
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var street: String = ""
    @State private var zip: String = ""
    @State private var city: String = ""
    @State private var instructions: String = ""
    
    var useInternationalNames: Bool
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
    }
    
    var body: some View {
        GeometryReader { metrics in

        ScrollView {
            VStack {
                Group {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["chip"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "contactData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String
                    )
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["contact"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "name", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
                )
                    .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["contact"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                               ) ["integerValue"] as? CGFloat ?? 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["contact"] as? [String: Any] ?? [:]
                              ) ["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["nameMaxLines"] as? [String: Any] ?? [:]
                              ) ["integerValue"] as? Int
                    )
                TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["nameSample"] as? [String: Any] ?? [:]
                          ) ["stringValue"] as! String,
                    text: $name,
                    onCommit: {
                        UserDefaults.standard.set(self.name, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as! String)
                    }
                )
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(NSPredicate(format:"SELF MATCHES %@", ContactActivity.nameRegex.pattern).evaluate(with: name)
                ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["contact"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["nameColor"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String)
                : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["contact"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["nameErrorColor"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String)
                    )
                ).padding(.bottom, 10)
                
                Text(
                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["contact"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) [DataHolder.internationalizeLabel(labelName: "phoneNumber", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                               ) ["stringValue"] as! String
                )
                    .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["contact"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                               ) ["integerValue"] as? CGFloat ?? 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["contact"] as? [String: Any] ?? [:]
                              ) ["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["phoneNumberMaxLines"] as? [String: Any] ?? [:]
                              ) ["integerValue"] as? Int
                    )
                }
                Group {
                    HStack {
                        let enableImportButton = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                       ) ["contact"] as? [String: Any] ?? [:]
                                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                       ) ["enableImportButton"] as? [String: Any] ?? [:]
                                                       ) ["booleanValue"] as! Bool

                        TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["phoneNumberSample"] as? [String: Any] ?? [:]
                                        ) ["stringValue"] as! String,
                                  text: $phoneNumber,
                                  onCommit: {
                                      UserDefaults.standard.set(self.phoneNumber, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                                                         ) ["main"] as? [String: Any] ?? [:]
                                                                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                                                         ) ["savedPhoneNumberKey"] as? [String: Any] ?? [:]
                                                                                         ) ["stringValue"] as! String)
                            DataHolder.phoneNumber = self.phoneNumber
                                  }
                        )
                        .foregroundColor(.black)
                        .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                            .fill(NSPredicate(format:"SELF MATCHES %@", ContactActivity.phoneNumberRegex.pattern).evaluate(with: phoneNumber)
                        ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["contact"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["phoneNumberColor"] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as! String)
                        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["contact"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["phoneNumberErrorColor"] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as! String)
                                 )
                        )
                        .padding(.bottom, 10)
                        .frame(width: metrics.size.width * (enableImportButton ? 0.8 : 1))

                        Spacer()

                        if (enableImportButton) {
                            Button(action: {
                                
                                // Get the contact store
                                let contactStore: CNContactStore = CNContactStore()

                                // Request access to the user's contacts
                                contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                                    if granted {
                                        do {
                                            let contacts = try contactStore.unifiedContacts(matching: CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: self.phoneNumber)), keysToFetch: [
                                                CNContactEmailAddressesKey,
                                                CNContactGivenNameKey,
                                                CNContactFamilyNameKey,
                                                CNContactPhoneNumbersKey,
                                                CNContactPostalAddressesKey
                                            ] as! [CNKeyDescriptor])

                                            if !contacts.isEmpty {
                                                let contact = contacts[0]
                                                let email = contact.emailAddresses.first?.value
                                                let phoneNumber = contact.phoneNumbers.first?.value.stringValue

                                                let street = contact.postalAddresses.first?.value.street
                                                let zip = contact.postalAddresses.first?.value.postalCode
                                                let city = contact.postalAddresses.first?.value.city
                                                
                                                if (contact.givenName != "") {
                                                    if (contact.familyName != "") {
                                                        let name = contact.givenName + " " + contact.familyName
                                                        
                                                        UserDefaults.standard.set(name, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["main"] as? [String: Any] ?? [:]
                                                                                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                                                       ) ["stringValue"] as! String)
                                                        self.name = String(name)
                                                        DataHolder.name = self.name
                                                    } else {
                                                        let name = contact.givenName
                                                        
                                                        UserDefaults.standard.set(name, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["main"] as? [String: Any] ?? [:]
                                                                                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                                                       ) ["stringValue"] as! String)
                                                        self.name = String(name)
                                                        DataHolder.name = self.name
                                                    }
                                                } else {
                                                    if (contact.familyName != "") {
                                                        let name = contact.familyName
                                                        
                                                        UserDefaults.standard.set(name, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["main"] as? [String: Any] ?? [:]
                                                                                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                                                       ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                                                       ) ["stringValue"] as! String)
                                                        self.name = String(name)
                                                        DataHolder.name = self.name
                                                    }
                                                }



                                                if (email != nil) {
                                                    UserDefaults.standard.set(email, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["savedEmailKey"] as? [String: Any] ?? [:]
                                                                                                        ) ["stringValue"] as! String)
                                                    self.email = String(email!)
                                                    DataHolder.email = self.email
                                                }



                                                if (street != nil) {
                                                    UserDefaults.standard.set(street, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["savedStreetKey"] as? [String: Any] ?? [:]
                                                                                                        ) ["stringValue"] as! String)
                                                    self.street = String(street!)
                                                    DataHolder.street = self.street
                                                }

                                            

                                                if (zip != nil) {
                                                    UserDefaults.standard.set(zip, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["savedZipKey"] as? [String: Any] ?? [:]
                                                                                                        ) ["stringValue"] as! String)
                                                    self.zip = String(zip!)
                                                    DataHolder.zip = self.zip
                                                }

                                            

                                                if (city != nil) {
                                                    UserDefaults.standard.set(city, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["savedCityKey"] as? [String: Any] ?? [:]
                                                                                                        ) ["stringValue"] as! String)
                                                    self.city = String(city!)
                                                    DataHolder.city = self.city
                                                }



                                                if (phoneNumber != nil) {
                                                    UserDefaults.standard.set(phoneNumber, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                                        ) ["savedPhoneNumberKey"] as? [String: Any] ?? [:]
                                                                                                        ) ["stringValue"] as! String)
                                                    self.phoneNumber = String(phoneNumber!)
                                                    DataHolder.phoneNumber = self.phoneNumber
                                                }


                                            } else {
                                                showingNoImportContactFoundAlert = true
                                            }
                                        } catch {
                                            showingAccessContactsError = true
                                        }
                                    }
                                })
                                
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(.title3))
                                    .foregroundColor(
                                        Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                            ) ["contact"] as? [String: Any] ?? [:]
                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                            ) ["importContactsContentColor"] as? [String: Any] ?? [:]
                                                            ) ["stringValue"] as! String)
                                    )
                            }
                            .background(RoundedRectangle(cornerRadius: metrics.size.width * 0.2).fill(
                                Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["contact"] as? [String: Any] ?? [:]
                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["importContactsBackgroundColor"] as? [String: Any] ?? [:]
                                                    ) ["stringValue"] as! String)
                            ))
                            .padding(.bottom, 10)
                            .frame(width: metrics.size.width * 0.2)
                            .alert(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["contact"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "noContactFound", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String, isPresented: $showingNoImportContactFoundAlert) {}
                            .alert(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) ["contact"] as? [String: Any] ?? [:]
                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) [DataHolder.internationalizeLabel(labelName: "accessContactsError", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                         ) ["stringValue"] as! String, isPresented: $showingAccessContactsError) {}
                        }
                    }
                }

                    
                
                Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) ["contact"] as? [String: Any] ?? [:]
                           ) ["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) [DataHolder.internationalizeLabel(labelName: "emailAddress", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                           ) ["stringValue"] as! String
                )
                    .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["contact"] as? [String: Any] ?? [:]
                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                                ) ["integerValue"] as? CGFloat ?? 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["contact"] as? [String: Any] ?? [:]
                              ) ["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["emailMaxLines"] as? [String: Any] ?? [:]
                              ) ["integerValue"] as? Int
                    )
                TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["emailAddressSample"] as? [String: Any] ?? [:]
                                ) ["stringValue"] as! String,
                          text: $email,
                          onCommit: {
                              UserDefaults.standard.set(self.email, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["main"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["savedEmailKey"] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as! String)
                    DataHolder.email = self.email
                          }
                )
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(
                    DataHolder.useWhatsApp != true
                    ? (NSPredicate(format:"SELF MATCHES %@", ContactActivity.emailRegex.pattern).evaluate(with: email)
                       ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["contact"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["emailColor"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String)
                       : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["contact"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["emailErrorColor"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String)
                      )
                    : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["contact"] as? [String: Any] ?? [:]
                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["emailGrayedOutColor"] as? [String: Any] ?? [:]
                                       ) ["stringValue"] as! String)
                    ))
                .padding(.bottom, 10)
                }
                
                Group {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["contact"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "streetAndNumber", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String
                    )
                        .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["contact"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                                   ) ["integerValue"] as? CGFloat ?? 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["contact"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["streetMaxLines"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? Int
                        )
                    TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["streetSample"] as? [String: Any] ?? [:]
                                     ) ["stringValue"] as! String,
                              text: $street,
                              onCommit: {
                                UserDefaults.standard.set(self.street, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                        ) ["main"] as? [String: Any] ?? [:]
                                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                                        ) ["savedStreetKey"] as? [String: Any] ?? [:]
                                                                                        ) ["stringValue"] as! String)
                                DataHolder.street = self.street
                              }
                    )
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(
                        DataHolder.deliveryMode == "delivery"
                        ? (NSPredicate(format:"SELF MATCHES %@", ContactActivity.streetRegex.pattern).evaluate(with: street)
                           ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["streetColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                           : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["streetErrorColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                          )
                        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["contact"] as? [String: Any] ?? [:]
                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["streetGrayedOutColor"] as? [String: Any] ?? [:]
                                           ) ["stringValue"] as! String)
                        ))
                    .padding(.bottom, 10)
                    
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["contact"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "zip", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String
                    )
                        .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["contact"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                                   ) ["integerValue"] as? CGFloat ?? 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["contact"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["zipMaxLines"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? Int
                        )
                    TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["zipSample"] as? [String: Any] ?? [:]
                                     ) ["stringValue"] as! String,
                              text: $zip,
                              onCommit: {
                                UserDefaults.standard.set(self.zip, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                                     ) ["main"] as? [String: Any] ?? [:]
                                                                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                                     ) ["savedZipKey"] as? [String: Any] ?? [:]
                                                                                     ) ["stringValue"] as! String)
                                DataHolder.zip = self.zip
                              })
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(
                        DataHolder.deliveryMode == "delivery"
                        ? (NSPredicate(format:"SELF MATCHES %@", ContactActivity.zipRegex.pattern).evaluate(with: zip)
                           ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["zipColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                           : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["zipErrorColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                          )
                        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["contact"] as? [String: Any] ?? [:]
                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["zipGrayedOutColor"] as? [String: Any] ?? [:]
                                           ) ["stringValue"] as! String)
                        ))
                    .padding(.bottom, 10)
                    
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["contact"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "city", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String
                    )
                        .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["contact"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                                   ) ["integerValue"] as? CGFloat ?? 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["contact"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cityMaxLines"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? Int
                        )
                    TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["citySample"] as? [String: Any] ?? [:]
                                     ) ["stringValue"] as! String,
                              text: $city,
                              onCommit: {
                                  UserDefaults.standard.set(self.city, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["main"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["savedCityKey"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
                        DataHolder.city = self.city
                              }
                    )
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(
                        DataHolder.deliveryMode == "delivery"
                        ? (NSPredicate(format:"SELF MATCHES %@", ContactActivity.cityRegex.pattern).evaluate(with: city)
                           ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["cityColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                           : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["cityErrorColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                          )
                        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["contact"] as? [String: Any] ?? [:]
                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["cityGrayedOutColor"] as? [String: Any] ?? [:]
                                           ) ["stringValue"] as! String)
                        ))
                    .padding(.bottom, 10)

                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["contact"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "instructions", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String
                    )
                        .font(.system(size: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["contact"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["inputTitleFontSize"] as? [String: Any] ?? [:]
                                                   ) ["integerValue"] as? CGFloat ?? 0))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["contact"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["instructionsMaxLines"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? Int
                        )
                    TextField(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["sampleUserContactData"] as? [String: Any] ?? [:]
                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["instructionsSample"] as? [String: Any] ?? [:]
                                     ) ["stringValue"] as! String,
                              text: $instructions,
                              onCommit: {
                                  UserDefaults.standard.set(self.instructions, forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["main"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["savedInstructionsKey"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
                        DataHolder.instructions = self.instructions
                              }
                    )
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(
                        NSPredicate(format:"SELF MATCHES %@", ContactActivity.instructionsRegex.pattern).evaluate(with: instructions)
                           ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["instructionsColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                           : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["contact"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["instructionsErrorColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String)
                          ))
                }
            }
            .onAppear {
                if let savedName = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["main"] as? [String: Any] ?? [:]
                                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                               ) ["stringValue"] as! String) {
                    name = savedName
                }
                if let savedEmail = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                                ) ["main"] as? [String: Any] ?? [:]
                                                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                                ) ["savedEmailKey"] as? [String: Any] ?? [:]
                                                                                ) ["stringValue"] as! String) {
                    email = savedEmail
                }
                if let savedStreet = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["main"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["savedStreetKey"] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as! String) {
                    street = savedStreet
                }
                if let savedZip = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                                              ) ["main"] as? [String: Any] ?? [:]
                                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                                              ) ["savedZipKey"] as? [String: Any] ?? [:]
                                                                              ) ["stringValue"] as! String) {
                    zip = savedZip
                }
                if let savedCity = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["main"] as? [String: Any] ?? [:]
                                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["savedCityKey"] as? [String: Any] ?? [:]
                                                                               ) ["stringValue"] as! String) {
                    city = savedCity
                }
                if let savedPhoneNumber = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["main"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["savedPhoneNumberKey"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String) {
                    phoneNumber = savedPhoneNumber
                }
                if let savedInstructions = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["main"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["savedInstructionsKey"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String) {
                    instructions = savedInstructions
                }
            }
            .onDisappear {
                DataHolder.name = name
                DataHolder.email = email
                DataHolder.street = street
                DataHolder.zip = zip
                DataHolder.city = city
                DataHolder.phoneNumber = phoneNumber
                DataHolder.instructions = instructions
            }
        }
    }
}
