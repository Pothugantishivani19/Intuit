// Copyright © 2021 Intuit, Inc. All rights reserved.
import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()
    private init() {}

    private let key = "favoriteBreedIds"

    private var favoriteIds: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: key) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: key) }
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }

    func toggle(_ id: String) {
        var ids = favoriteIds
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        favoriteIds = ids
    }
}
