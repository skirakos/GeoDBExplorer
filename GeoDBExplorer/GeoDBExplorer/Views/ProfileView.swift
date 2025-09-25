//
//  ProfileView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section("Account") {
                HStack(spacing: 16) {
                    ZStack {
                        if let ui = vm.avatarImage {
                            Image(uiImage: ui).resizable().scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().scaledToFit().foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.quaternary, lineWidth: 1))

                    VStack(spacing: 6) {
                        TextField("First name", text: $vm.firstName)
                            .textContentType(.givenName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .font(.title3.weight(.semibold))

                        TextField("Last name", text: $vm.lastName)
                            .textContentType(.familyName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .font(.title3.weight(.semibold))
                    }
                }

                HStack {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo")
                    }
                    Spacer()
                    if vm.avatarImage != nil {
                        Button(role: .destructive) { vm.removeAvatar() } label: { Text("Remove") }
                    }
                }
            }

            Section("Preferences") {
                Picker("Language", selection: $vm.language) {
                    Text("English").tag("en")
                    Text("Հայերեն").tag("hy")
                }
                .pickerStyle(.segmented)
            }

            Section("About me") {
                TextEditor(text: $vm.bio).frame(minHeight: 96)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pickerItem) { _, newValue in
            Task {
                guard
                    let item = newValue,
                    let data = try? await item.loadTransferable(type: Data.self)
                else { return }
                vm.setAvatar(from: data)
            }
        }
    }
}
