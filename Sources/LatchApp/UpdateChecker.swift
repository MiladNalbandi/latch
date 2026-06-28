import Foundation

/// Checks GitHub Releases for a newer version. Latch is unsigned (no Sparkle auto-update),
/// so this only *notifies* — the user downloads the new DMG from the releases page.
enum UpdateChecker {
    /// Change this single constant if the repository is renamed.
    static let repo = "MiladNalbandi/latch"

    enum Result {
        case upToDate(current: String)
        case available(version: String, url: URL)
        case failed
    }

    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    static var releasesPage: URL {
        URL(string: "https://github.com/\(repo)/releases/latest")!
    }

    static func check(completion: @escaping (Result) -> Void) {
        // The list endpoint includes pre-releases (newest first); the "/latest" endpoint
        // would ignore them, and Latch's releases are currently all pre-releases.
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases?per_page=20") else {
            completion(.failed); return
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        URLSession.shared.dataTask(with: request) { data, _, _ in
            let result = parse(data)
            DispatchQueue.main.async { completion(result) }
        }.resume()
    }

    private static func parse(_ data: Data?) -> Result {
        guard let data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return .failed }

        // Newest non-draft release (the API returns newest first).
        guard let latest = json.first(where: { ($0["draft"] as? Bool) != true }),
              let tag = latest["tag_name"] as? String
        else { return .failed }

        let version = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
        let page = (latest["html_url"] as? String).flatMap(URL.init(string:)) ?? releasesPage

        return isNewer(version, than: currentVersion)
            ? .available(version: version, url: page)
            : .upToDate(current: currentVersion)
    }

    /// Numeric, dotted-version comparison (e.g. "0.2.10" > "0.2.9").
    static func isNewer(_ a: String, than b: String) -> Bool {
        let pa = a.split(separator: ".").map { Int($0) ?? 0 }
        let pb = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0 ..< max(pa.count, pb.count) {
            let x = i < pa.count ? pa[i] : 0
            let y = i < pb.count ? pb[i] : 0
            if x != y { return x > y }
        }
        return false
    }
}
