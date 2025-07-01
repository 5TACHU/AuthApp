//
//  LoginView.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Text("Logowanie").font(.largeTitle)

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Hasło", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Zaloguj") {
                    auth.login(email: email, password: password)
                }

                Button("Nie masz konta? Zarejestruj się") {
                    path.append("register")
                }
            }
            .padding()
            .alert(isPresented: $auth.showAlert) {
                Alert(title: Text("Informacja"), message: Text(auth.message), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(for: String.self) { route in
                if route == "register" {
                    RegisterView()
                }
            }
        }
    }
}
