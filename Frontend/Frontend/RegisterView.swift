//
//  RegisterView.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Rejestracja").font(.largeTitle)

            TextField("Email", text: $email).autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Hasło", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Zarejestruj") {
                auth.register(email: email, password: password)
            }
        }
        .padding()
        .alert(isPresented: $auth.showAlert) {
            Alert(title: Text("Informacja"), message: Text(auth.message), dismissButton: .default(Text("OK")))
        }
    }
}
