//
//  ContentView.swift
//  firebase_project
//
//  Created by Gaming Lab on 14/11/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoggedIn = false
    @State private var isSignUp = true
    @State private var userName = ""
    @State private var errorMessage = ""

    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStack(spacing: 20) {
                
                if isLoggedIn {
                    Text("Welcome,\n \(userName)!")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .offset(x: -100, y: -100)
                    
                    Button(action: logOut) {
                        Text("Log Out")
                            .bold()
                            .frame(width: 200, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.linearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottomTrailing)))
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                } else {
                    if isSignUp {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .offset(x: -100, y: -100)
                        
                        CustomTextField(placeholder: "Name", text: $name)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomSecureField(placeholder: "Password", text: $password)
                        
                        Button {
                            signUp()
                        } label: {
                            Text("Sign Up")
                                .bold()
                                .frame(width: 200, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.linearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottomTrailing)))
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            isSignUp = false
                        } label: {
                            Text("Already have an account?")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        .offset(y: 110)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .offset(x: -100, y: -100)
                        
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomSecureField(placeholder: "Password", text: $password)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        
                        Button {
                            login()
                        } label: {
                            Text("Login")
                                .bold()
                                .frame(width: 200, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.linearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottomTrailing)))
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            isSignUp = true
                        } label: {
                            Text("Don't have an account?")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        .offset(y: 110)
                    }
                }
            }
            .frame(width: 350)
        }
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Error creating user: \(error.localizedDescription)"
            } else {
                let userRef = db.collection("users").document(result!.user.uid)
                userRef.setData([
                    "name": name,
                    "email": email
                ]) { err in
                    if let err = err {
                        errorMessage = "Error saving user data: \(err.localizedDescription)"
                    } else {
                        isLoggedIn = true
                        userName = name
                    }
                }
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Invalid login credentials. Please try again."
            } else {
                let userRef = db.collection("users").document(result!.user.uid)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let userData = document.data() {
                            userName = userData["name"] as? String ?? "Unknown"
                            isLoggedIn = true
                        }
                    } else {
                        errorMessage = "User data not found."
                    }
                }
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            userName = ""
        } catch {
            errorMessage = "Error logging out: \(error.localizedDescription)"
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.white)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .frame(width: 350)
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .foregroundColor(.white)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .frame(width: 350)
    }
}
