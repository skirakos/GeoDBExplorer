//
//  ProfileView.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 19.09.25.
//

import CoreLocation



import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("profile.firstName") private var firstName = ""
    @AppStorage("profile.lastName")  private var lastName  = ""
    @AppStorage("profile.bio")       private var bio       = ""
    @AppStorage("app.language")      private var lang      = "en"

    // Avatar
    @State private var avatarImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?

    private var avatarURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
    }

    var body: some View {
        Form {
            // Account
            Section("Account") {
                HStack(spacing: 16) {
                    ZStack {
                        if let ui = avatarImage {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.quaternary, lineWidth: 1))

                    VStack(spacing: 6) {
                        TextField("First name", text: $firstName)
                            .textContentType(.givenName)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.next)
                            .font(.title3.weight(.semibold))

                        TextField("Last name", text: $lastName)
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
                    if avatarImage != nil {
                        Button(role: .destructive) {
                            removeAvatar()
                        } label: {
                            Text("Remove")
                        }
                    }
                }
            }

            // Preferences
            Section("Preferences") {
                Picker("Language", selection: $lang) {
                    Text("English").tag("en")
                    Text("Հայերեն").tag("hy")
                }
                .pickerStyle(.segmented)
            }

            // About me
            Section("About me") {
                TextEditor(text: $bio)
                    .frame(minHeight: 96)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Load avatar from disk once
            if avatarImage == nil, FileManager.default.fileExists(atPath: avatarURL.path) {
                avatarImage = UIImage(contentsOfFile: avatarURL.path)
            }
        }
        .onChange(of: pickerItem) { _, newValue in
            Task {
                guard
                    let item = newValue,
                    let data = try? await item.loadTransferable(type: Data.self),
                    let image = UIImage(data: data)
                else { return }

                avatarImage = image
                try? data.write(to: avatarURL, options: .atomic)
            }
        }
    }

    private func removeAvatar() {
        try? FileManager.default.removeItem(at: avatarURL)
        avatarImage = nil
    }
}



#Preview {
    ProfileView()
}
