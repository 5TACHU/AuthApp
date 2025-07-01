//
//  MainView.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import SwiftUI

struct MainView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var newPassword = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Zalogowany").font(.title)

            SecureField("Nowe hasło", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Zmień hasło") {
                auth.changePassword(newPassword: newPassword)
            }

            Button("Usuń konto") {
                auth.deleteAccount()
            }

            Button("Wyloguj się") {
                auth.logout()
            }
        }
        .padding()
    }
}
