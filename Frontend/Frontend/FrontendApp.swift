//
//  FrontendApp.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import SwiftUI

@main
struct FrontendApp: App {
    
    @StateObject var auth = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(auth)
        }
    }
}
