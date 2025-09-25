//
//  ProfileViewModel.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 26.09.25.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var firstName: String { didSet { save("profile.firstName", firstName) } }
    @Published var lastName:  String { didSet { save("profile.lastName",  lastName)  } }
    @Published var bio:       String { didSet { save("profile.bio",       bio)       } }
    @Published var language:  String { didSet { save("app.language",      language)  } }

    @Published var avatarImage: UIImage?

    private let defaults: UserDefaults
    private let fileManager: FileManager

    private var avatarURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
    }

    init(
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) {
        self.defaults = defaults
        self.fileManager = fileManager

        self.firstName = defaults.string(forKey: "profile.firstName") ?? ""
        self.lastName  = defaults.string(forKey: "profile.lastName")  ?? ""
        self.bio       = defaults.string(forKey: "profile.bio")       ?? ""
        self.language  = defaults.string(forKey: "app.language")      ?? "en"

        if fileManager.fileExists(atPath: avatarURL.path) {
            self.avatarImage = UIImage(contentsOfFile: avatarURL.path)
        }
    }

    func setAvatar(from data: Data) {
        guard let image = UIImage(data: data) else { return }
        avatarImage = image
        try? data.write(to: avatarURL, options: .atomic)
    }

    func removeAvatar() {
        try? fileManager.removeItem(at: avatarURL)
        avatarImage = nil
    }

    private func save(_ key: String, _ value: String) {
        defaults.set(value, forKey: key)
    }
}
