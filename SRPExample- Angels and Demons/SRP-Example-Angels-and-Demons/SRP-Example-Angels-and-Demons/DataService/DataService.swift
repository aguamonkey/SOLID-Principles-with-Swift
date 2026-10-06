import Foundation

protocol DataServiceProtocol {
    func getAllAngels() async throws -> [AngelModel]
    func getAllDemons() async throws -> [DemonModel]
}

/// Local teaching fixtures; the powers and ranks are illustrative, not a reference theology.
struct DataService: DataServiceProtocol {
    func getAllAngels() async throws -> [AngelModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [AngelModel(id: "michael", name: "Michael", power: "Healing"),
                AngelModel(id: "gabriel", name: "Gabriel", power: "Messenger")]
    }
    func getAllDemons() async throws -> [DemonModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [DemonModel(id: "lucifer", name: "Lucifer", ability: "Illusion"),
                DemonModel(id: "mammon", name: "Mammon", ability: "Greed")]
    }
}
