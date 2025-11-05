import Foundation

final class ChatStore: ObservableObject {
    @Published var chats: [Chat] = []
    private let saveKey = "chats.json"
    
    // MARK: - Init
    init() {
        load()
    }
    
    // MARK: - Public API
    
    @discardableResult
    func createChat(title: String) -> Chat {
        let chat = Chat(title: title)
        chats.append(chat)
        save()
        return chat
    }

    func renameChat(id: UUID, to newTitle: String) {
        guard let idx = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[idx].title = newTitle
        save()
    }

    func deleteChat(id: UUID) {
        guard let idx = chats.firstIndex(where: { $0.id == id }) else { return }
        chats.remove(at: idx)
        save()
    }
    
    func addChat(title: String) {
        chats.append(Chat(title: title))
        save()
    }
    
    func addMessage(_ message: Message, to chat: Chat) {
        guard let idx = chats.firstIndex(where: { $0.id == chat.id }) else { return }
        chats[idx].messages.append(message)
        save()
    }
    
    // MARK: - Persistence
    private func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(saveKey)
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(chats)
            try data.write(to: fileURL())
        } catch {
            print("⚠️ Failed to save chats:", error.localizedDescription)
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL())
            chats = try JSONDecoder().decode([Chat].self, from: data)
        } catch {
            print("ℹ️ No saved chats or failed to decode:", error.localizedDescription)
            chats = []
        }
    }
}
