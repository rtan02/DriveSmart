import Foundation
struct ChecklistItem: Identifiable {
    let id = UUID()
    var name: String
    var isChecked: Bool
}
