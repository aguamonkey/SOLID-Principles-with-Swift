import Foundation

/// A voice that can take part in a descriptive (not audio) performance.
///
/// Behaviour required of every conformer:
/// - `id` and `name` remain stable when `play()` is called.
/// - `play()` returns a nonblank description identifying this instrument by name.
/// - Playing works immediately and repeatedly: no tuning, blowing, audio resource,
///   downcast, or other concrete-type preparation is required by the caller.
///
/// Swift checks the signatures; the shared contract tests check these behaviours.
protocol Playable {
    var id: UUID { get }
    var name: String { get }
    func play() -> String
}
