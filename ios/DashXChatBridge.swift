import Foundation
import DashX

/// Holds the conversation leases opened from JS and turns their callbacks into
/// `chatConversationEvent` events. JS names each lease with an id of its own, so
/// opening needs no round trip.
final class DashXChatBridge {
    static let eventName = "chatConversationEvent"

    private struct Entry {
        let lease: DashXConversationLease
        let observer: DashXConversationStateObserver
    }

    private final class ClientMessageId {
        var value: String?
    }

    private let lock = NSLock()
    private var entries: [String: Entry] = [:]
    private let emit: ([String: Any]) -> Void

    init(emit: @escaping ([String: Any]) -> Void) {
        self.emit = emit
    }

    // MARK: - Leases

    func open(leaseId: String, chatIdentityId: String, conversationId: String) {
        let emit = self.emit
        let lease = DashXClient.instance.chat(chatIdentityId: chatIdentityId).openConversation(conversationId)
        let updates = StateUpdates()
        let observer = DashXConversationStateObserver { state in
            updates.send(state, leaseId: leaseId, emit: emit)
        }
        lease.setOnTerminated { _ in
            emit(["leaseId": leaseId, "type": "terminated", "reason": "sessionEnded"])
        }

        lock.lock()
        let replaced = entries.updateValue(Entry(lease: lease, observer: observer), forKey: leaseId)
        lock.unlock()
        replaced?.lease.close()

        lease.addStateListener(observer)
    }

    func close(leaseId: String) {
        lock.lock()
        let entry = entries.removeValue(forKey: leaseId)
        lock.unlock()
        entry?.lease.setOnTerminated(nil)
        entry?.lease.close()
    }

    func closeAll() {
        lock.lock()
        let open = Array(entries.values)
        entries.removeAll()
        lock.unlock()
        open.forEach {
            $0.lease.setOnTerminated(nil)
            $0.lease.close()
        }
    }

    func setVisible(leaseId: String, visible: Bool) {
        lease(leaseId)?.setVisible(visible)
    }

    func sendMessage(
        leaseId: String,
        content: [String: Any],
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard let lease = lease(leaseId) else {
            DashXChatBridge.reject(reject, DashXClientError.sessionEnded)
            return
        }
        // Assigned when `sendMessage` returns, which is before the request completes.
        let clientMessageId = ClientMessageId()
        clientMessageId.value = lease.sendMessage(content: content) { result in
            switch result {
            case .success(let message):
                resolve(DashXChatBridge.serialize(message))
            case .failure(let error):
                DashXChatBridge.reject(reject, error, clientMessageId: clientMessageId.value)
            }
        }
    }

    func loadPreviousPage(leaseId: String, requestId: Double) {
        let emit = self.emit
        let onComplete = {
            emit(["leaseId": leaseId, "type": "loadPreviousPageComplete", "requestId": requestId])
        }
        guard let lease = lease(leaseId) else {
            onComplete()
            return
        }
        lease.loadPreviousPage(onError: { error in
            emit([
                "leaseId": leaseId,
                "type": "loadPreviousPageError",
                "requestId": requestId,
                "error": DashXChatBridge.serialize(error),
            ])
        }, onComplete: onComplete)
    }

    private func lease(_ leaseId: String) -> DashXConversationLease? {
        lock.lock()
        defer { lock.unlock() }
        return entries[leaseId]?.lease
    }

    // MARK: - Identity-scoped operations

    func fetchConversations(
        chatIdentityId: String,
        options: NSDictionary?,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DashXClient.instance.chat(chatIdentityId: chatIdentityId).fetchConversations(
            limit: options?["limit"] as? Int,
            page: options?["page"] as? Int,
            statuses: options?["statuses"] as? [String],
            properties: options?["properties"] as? [String: Any]
        ) { result in
            switch result {
            case .success(let conversations): resolve(conversations.map { DashXChatBridge.serialize($0) })
            case .failure(let error): DashXChatBridge.reject(reject, error)
            }
        }
    }

    func fetchConversation(
        chatIdentityId: String,
        conversationId: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DashXClient.instance.chat(chatIdentityId: chatIdentityId).fetchConversation(conversationId) { result in
            switch result {
            case .success(let conversation): resolve(DashXChatBridge.serialize(conversation))
            case .failure(let error): DashXChatBridge.reject(reject, error)
            }
        }
    }

    func summarizeConversations(
        chatIdentityId: String,
        options: NSDictionary?,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DashXClient.instance.chat(chatIdentityId: chatIdentityId).summarizeConversations(
            statuses: options?["statuses"] as? [String],
            properties: options?["properties"] as? [String: Any]
        ) { result in
            switch result {
            case .success(let count): resolve(count)
            case .failure(let error): DashXChatBridge.reject(reject, error)
            }
        }
    }

    func summarizeUnread(
        chatIdentityId: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DashXClient.instance.chat(chatIdentityId: chatIdentityId).summarizeUnread { result in
            switch result {
            case .success(let count): resolve(count)
            case .failure(let error): DashXChatBridge.reject(reject, error)
            }
        }
    }

    func resolveConversation(
        chatIdentityId: String,
        conversationId: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DashXClient.instance.chat(chatIdentityId: chatIdentityId).resolveConversation(conversationId) { result in
            switch result {
            case .success(let conversation): resolve(DashXChatBridge.serialize(conversation))
            case .failure(let error): DashXChatBridge.reject(reject, error)
            }
        }
    }

    // MARK: - Serialization

    static func serialize(_ state: DashXConversationState) -> [String: Any] {
        switch state {
        case .loading:
            return ["status": "loading"]
        case .ready(let messages, let hasOlderMessages, let streamingReply):
            return [
                "status": "ready",
                "messages": messages.map { serialize($0) },
                "hasOlderMessages": hasOlderMessages,
                "streamingReply": serialize(streamingReply),
            ]
        case .error(let error):
            return ["status": "error", "error": serialize(error)]
        }
    }

    static func serialize(_ message: DashXChatMessage) -> [String: Any] {
        return [
            "id": message.id,
            "conversationId": message.conversationId,
            "externalUid": message.externalUid ?? NSNull(),
            "clientMessageId": message.clientMessageId ?? NSNull(),
            "senderId": message.senderId ?? NSNull(),
            "aiRole": message.aiRole ?? NSNull(),
            "turnSeq": message.turnSeq,
            "renderedContent": message.renderedContent.mapValues { $0 ?? NSNull() },
            "createdAt": message.createdAt ?? NSNull(),
            "sentAt": message.sentAt ?? NSNull(),
        ]
    }

    static func serialize(_ reply: DashXStreamingReply?) -> Any {
        guard let reply else { return NSNull() }
        return ["turnSeq": reply.turnSeq, "text": reply.text, "isComplete": reply.isComplete]
    }

    static func serialize(_ conversation: DashXChatConversationSummary) -> [String: Any] {
        var context: Any = NSNull()
        if let value = conversation.context {
            context = [
                "kind": value.kind,
                "subtype": value.subtype ?? NSNull(),
                "id": value.id,
                "reference": value.reference ?? NSNull(),
                "name": value.name ?? NSNull(),
            ] as [String: Any]
        }
        var topic: Any = NSNull()
        if let value = conversation.topic {
            topic = ["id": value.id, "label": value.label]
        }
        return [
            "conversationId": conversation.conversationId,
            "category": conversation.category,
            "context": context,
            "topic": topic,
            "status": conversation.status,
            "title": conversation.title,
            "lastMessagePreview": conversation.lastMessagePreview ?? NSNull(),
            "lastMessageAt": conversation.lastMessageAt ?? NSNull(),
            "lastSenderKind": conversation.lastSenderKind ?? NSNull(),
            "activityAt": conversation.activityAt,
            "assignedGroups": conversation.assignedGroups.map { ["id": $0.id, "name": $0.name] },
            "unreadCount": conversation.unreadCount,
        ]
    }

    static func serialize(_ error: Error) -> [String: Any] {
        return ["code": code(for: error), "message": error.localizedDescription]
    }

    /// The same codes the Android bridge reports; a GraphQL error reports the backend's own code.
    static func code(for error: Error) -> String {
        guard let error = error as? DashXClientError else { return "EUNSPECIFIED" }
        switch error {
        case .graphQLErrors(let errors): return errors.code ?? "GRAPHQL_ERROR"
        case .networkError: return "NETWORK_ERROR"
        case .sessionEnded: return "SESSION_ENDED"
        case .subscriptionFailed: return "SUBSCRIPTION_FAILED"
        case .notIdentified: return "NOT_IDENTIFIED"
        default: return "EUNSPECIFIED"
        }
    }

    private static func reject(_ reject: RCTPromiseRejectBlock, _ error: Error, clientMessageId: String? = nil) {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: error.localizedDescription]
        if let clientMessageId = clientMessageId {
            userInfo["clientMessageId"] = clientMessageId
        }
        reject(
            code(for: error),
            error.localizedDescription,
            NSError(domain: "DashXChat", code: 0, userInfo: userInfo)
        )
    }
}

/// Decides what one lease's next state event carries. JS caches the last state, so when only the
/// streamed reply changed, the messages and paging it already holds are not sent again.
final class StateUpdates {
    private let lock = NSLock()
    private var sentReady: (messages: [DashXChatMessage], hasOlderMessages: Bool)?

    /// `emit` runs under the lock, so updates reach JS in the order they were decided. The SDK hands
    /// over the same messages array when only the reply changed, so the comparison is a buffer check.
    func send(_ state: DashXConversationState, leaseId: String, emit: ([String: Any]) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard case .ready(let messages, let hasOlderMessages, let streamingReply) = state else {
            sentReady = nil
            emit(["leaseId": leaseId, "type": "state", "state": DashXChatBridge.serialize(state)])
            return
        }
        let previous = sentReady
        sentReady = (messages, hasOlderMessages)
        if let previous, previous.hasOlderMessages == hasOlderMessages, previous.messages == messages {
            let reply = DashXChatBridge.serialize(streamingReply)
            emit(["leaseId": leaseId, "type": "streamingReply", "streamingReply": reply])
        } else {
            emit(["leaseId": leaseId, "type": "state", "state": DashXChatBridge.serialize(state)])
        }
    }
}
