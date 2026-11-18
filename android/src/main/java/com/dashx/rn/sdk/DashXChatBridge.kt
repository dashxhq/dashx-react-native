package com.dashx.rn.sdk

import com.dashx.android.DashX
import com.dashx.android.DashXError
import com.dashx.android.chat.ChatMessage
import com.dashx.android.chat.ConversationState
import com.dashx.android.chat.ConversationStateListener
import com.dashx.android.chat.DashXConversationLease
import com.dashx.android.chat.chat
import com.dashx.android.graphql.generated.fragment.ChatConversationSummaryFragment
import com.dashx.rn.sdk.util.WritableFactory
import com.dashx.rn.sdk.util.convertJsonToMap
import com.dashx.rn.sdk.util.convertMapToJson
import com.dashx.rn.sdk.util.getIntIfPresent
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableType
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicReference

/**
 * Holds the conversation leases opened from JS and turns their callbacks into
 * `chatConversationEvent` events. JS names each lease with an id of its own, so
 * opening needs no round trip.
 */
internal class DashXChatBridge(private val reactContext: ReactApplicationContext) {
    private val leases = ConcurrentHashMap<String, DashXConversationLease>()

    // ---- leases ----

    fun open(leaseId: String, chatIdentityId: String, conversationId: String) {
        val lease = DashX.chat(chatIdentityId).openConversation(conversationId)
        lease.setOnTerminated {
            emit(leaseId, "terminated") { putString("reason", "sessionEnded") }
        }
        leases.put(leaseId, lease)?.close()
        // Replays the current state, so JS gets one without asking.
        lease.addStateListener(ConversationStateListener { state ->
            emit(leaseId, "state") { putMap("state", stateToMap(state)) }
        })
    }

    fun close(leaseId: String) {
        leases.remove(leaseId)?.let(::closeLease)
    }

    fun closeAll() {
        val open = leases.values.toList()
        leases.clear()
        open.forEach(::closeLease)
    }

    private fun closeLease(lease: DashXConversationLease) {
        lease.setOnTerminated(null)
        lease.close()
    }

    fun setVisible(leaseId: String, visible: Boolean) {
        leases[leaseId]?.setVisible(visible)
    }

    fun sendMessage(leaseId: String, content: ReadableMap, promise: Promise) {
        val lease = leases[leaseId]
        if (lease == null) {
            reject(promise, DashXError.SessionEnded())
            return
        }
        val json = convertMapToJson(content)
        if (json == null) {
            promise.reject(E_INVALID, "content must be a plain object")
            return
        }
        // Set when `sendMessage` returns, which is before the request completes.
        val clientMessageId = AtomicReference<String?>(null)
        clientMessageId.set(
            lease.sendMessage(
                content = json,
                onSuccess = { message -> promise.resolve(messageToMap(message)) },
                onError = { error -> reject(promise, error, clientMessageId.get()) }
            )
        )
    }

    fun loadPreviousPage(leaseId: String, requestId: Double) {
        leases[leaseId]?.loadPreviousPage { error ->
            emit(leaseId, "loadPreviousPageError") {
                putDouble("requestId", requestId)
                putMap("error", errorToMap(error))
            }
        }
    }

    // ---- identity-scoped operations ----

    fun fetchConversations(chatIdentityId: String, options: ReadableMap?, promise: Promise) {
        DashX.chat(chatIdentityId).fetchConversations(
            limit = options?.getIntIfPresent("limit"),
            page = options?.getIntIfPresent("page"),
            statuses = options?.getStringList("statuses"),
            properties = convertMapToJson(options?.getMapOrNull("properties")),
            onSuccess = { conversations ->
                val array = WritableFactory.createArray()
                conversations.forEach { array.pushMap(conversationToMap(it.chatConversationSummaryFragment)) }
                promise.resolve(array)
            },
            onError = { reject(promise, it) }
        )
    }

    fun fetchConversation(chatIdentityId: String, conversationId: String, promise: Promise) {
        DashX.chat(chatIdentityId).fetchConversation(
            conversationId,
            onSuccess = { promise.resolve(conversationToMap(it.chatConversationSummaryFragment)) },
            onError = { reject(promise, it) }
        )
    }

    fun summarizeConversations(chatIdentityId: String, options: ReadableMap?, promise: Promise) {
        DashX.chat(chatIdentityId).summarizeConversations(
            statuses = options?.getStringList("statuses"),
            properties = convertMapToJson(options?.getMapOrNull("properties")),
            onSuccess = { promise.resolve(it) },
            onError = { reject(promise, it) }
        )
    }

    fun summarizeUnread(chatIdentityId: String, promise: Promise) {
        DashX.chat(chatIdentityId).summarizeUnread(
            onSuccess = { promise.resolve(it) },
            onError = { reject(promise, it) }
        )
    }

    fun resolveConversation(chatIdentityId: String, conversationId: String, promise: Promise) {
        DashX.chat(chatIdentityId).resolveConversation(
            conversationId,
            onSuccess = { promise.resolve(conversationToMap(it.chatConversationSummaryFragment)) },
            onError = { reject(promise, it) }
        )
    }

    // ---- events ----

    private fun emit(leaseId: String, type: String, fill: WritableMap.() -> Unit) {
        // Nothing can receive the event while React is reloading or torn down.
        if (!reactContext.hasActiveReactInstance()) return
        val body = WritableFactory.createMap().apply {
            putString("leaseId", leaseId)
            putString("type", type)
            fill()
        }
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
            .emit(EVENT_NAME, body)
    }

    companion object {
        const val EVENT_NAME = "chatConversationEvent"
        private const val E_INVALID = "EINVAL"

        fun stateToMap(state: ConversationState): WritableMap = WritableFactory.createMap().apply {
            when (state) {
                is ConversationState.Loading -> putString("status", "loading")
                is ConversationState.Ready -> {
                    putString("status", "ready")
                    val messages = WritableFactory.createArray()
                    state.messages.forEach { messages.pushMap(messageToMap(it)) }
                    putArray("messages", messages)
                    putBoolean("hasOlderMessages", state.hasOlderMessages)
                    putMap("streamingReply", state.streamingReply?.let { reply ->
                        WritableFactory.createMap().apply {
                            putDouble("turnSeq", reply.turnSeq.toDouble())
                            putString("text", reply.text)
                            putBoolean("isComplete", reply.isComplete)
                        }
                    })
                }
                is ConversationState.Error -> {
                    putString("status", "error")
                    putMap("error", errorToMap(state.cause))
                }
            }
        }

        fun messageToMap(message: ChatMessage): WritableMap = WritableFactory.createMap().apply {
            putString("id", message.id)
            putString("conversationId", message.conversationId)
            putString("externalUid", message.externalUid)
            putString("clientMessageId", message.clientMessageId)
            putString("senderId", message.senderId)
            putString("aiRole", message.aiRole)
            putDouble("turnSeq", message.turnSeq.toDouble())
            putMap("renderedContent", convertJsonToMap(message.renderedContent))
            putString("createdAt", message.createdAt)
            putString("sentAt", message.sentAt)
        }

        fun conversationToMap(conversation: ChatConversationSummaryFragment): WritableMap =
            WritableFactory.createMap().apply {
                putString("conversationId", conversation.conversationId.toString())
                putString("category", conversation.category)
                putMap("context", conversation.context?.let { context ->
                    WritableFactory.createMap().apply {
                        putString("kind", context.kind)
                        putString("subtype", context.subtype)
                        putString("id", context.id)
                        putString("reference", context.reference)
                        putString("name", context.name)
                    }
                })
                putMap("topic", conversation.topic?.let { topic ->
                    WritableFactory.createMap().apply {
                        putString("id", topic.id)
                        putString("label", topic.label)
                    }
                })
                putString("status", conversation.status)
                putString("title", conversation.title)
                putString("lastMessagePreview", conversation.lastMessagePreview)
                putString("lastMessageAt", conversation.lastMessageAt)
                putString("lastSenderKind", conversation.lastSenderKind)
                putString("activityAt", conversation.activityAt)
                val groups = WritableFactory.createArray()
                conversation.assignedGroups.forEach { group ->
                    groups.pushMap(WritableFactory.createMap().apply {
                        putString("id", group.id)
                        putString("name", group.name)
                    })
                }
                putArray("assignedGroups", groups)
                putInt("unreadCount", conversation.unreadCount)
            }

        fun errorToMap(error: DashXError): WritableMap = WritableFactory.createMap().apply {
            putString("code", codeFor(error))
            putString("message", error.message)
        }

        /** The same codes the iOS bridge reports; a GraphQL error reports the backend's own code. */
        fun codeFor(error: DashXError): String = when (error) {
            is DashXError.GraphQLError -> error.code ?: "GRAPHQL_ERROR"
            is DashXError.NetworkError -> "NETWORK_ERROR"
            is DashXError.SessionEnded -> "SESSION_ENDED"
            is DashXError.SubscriptionFailed -> "SUBSCRIPTION_FAILED"
            is DashXError.NotIdentified -> "NOT_IDENTIFIED"
            is DashXError.NotConfigured -> "NOT_CONFIGURED"
            else -> "EUNSPECIFIED"
        }

        private fun reject(promise: Promise, error: DashXError, clientMessageId: String? = null) {
            if (clientMessageId == null) {
                promise.reject(codeFor(error), error.message)
                return
            }
            val userInfo = WritableFactory.createMap().apply { putString("clientMessageId", clientMessageId) }
            promise.reject(codeFor(error), error.message, userInfo)
        }

        private fun ReadableMap.getMapOrNull(key: String): ReadableMap? =
            if (hasKey(key) && getType(key) == ReadableType.Map) getMap(key) else null

        private fun ReadableMap.getStringList(key: String): List<String>? {
            if (!hasKey(key) || getType(key) != ReadableType.Array) return null
            val array = getArray(key) ?: return null
            return (0 until array.size()).mapNotNull { i ->
                if (array.getType(i) == ReadableType.String) array.getString(i) else null
            }
        }
    }
}
