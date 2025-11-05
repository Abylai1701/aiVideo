import SwiftUI

struct ChatDetailView: View {
    let chat: Chat
    @ObservedObject var store: ChatStore
    @State private var text = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(chat.messages) { message in
                            MessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 12)
                    .onChange(of: chat.messages.count) { _ in
                        if let last = chat.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            // MARK: - Поле ввода
            HStack(spacing: 10) {
                TextField("Start typing a prompt", text: $text)
                    .padding(12)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
                    .font(.system(size: 16))
                    .overlay(
                        HStack {
                            Spacer()
                            Button {
                                // TODO: выбор фото (потом добавим)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.black)
                            }
                            .padding(.trailing, 16)
                        }
                    )

                Button {
                    guard !text.isEmpty else { return }
                    store.addMessage(Message(text: text, isUser: true), to: chat)
                    text = ""
                } label: {
                    ZStack {
                        Circle()
                            .fill(text.isEmpty
                                  ? Color(red: 0.97, green: 0.87, blue: 0.62)
                                  : Color(red: 0.93, green: 0.70, blue: 0.10))
                            .frame(width: 36, height: 36)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white)
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}

// MARK: - MessageRow

// MARK: - MessageRow (только фото у бота)
struct MessageRow: View {
    let message: Message

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {

            if let data = message.imageData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: message.isUser ? 100.fitW : 260.fitW,
                        height: message.isUser ? 100.fitW : 260.fitW
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: .infinity,
                           alignment: message.isUser ? .trailing : .leading)
            }

            if message.isUser, !message.text.isEmpty {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundStyle(.black101010)
                    .font(.interMedium(size: 16))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.grayF5F5F5)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .transition(.opacity)
    }
}
