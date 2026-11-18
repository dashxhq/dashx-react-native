package com.dashx.rn.sdk

import com.dashx.android.DashXError
import com.dashx.android.chat.ChatMessage
import com.dashx.android.chat.ChatStreamingReply
import com.dashx.android.chat.ConversationState
import com.dashx.android.graphql.generated.fragment.ChatConversationSummaryFragment
import com.dashx.rn.sdk.util.WritableFactory
import com.facebook.react.bridge.JavaOnlyArray
import com.facebook.react.bridge.JavaOnlyMap
import com.facebook.react.bridge.ReadableType
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

/** The shapes the chat bridge hands to JS; `index.d.ts` documents the same ones. */
class DashXChatBridgeTest {

    @Before
    fun setUp() {
        WritableFactory.createMap = { JavaOnlyMap() }
        WritableFactory.createArray = { JavaOnlyArray() }
    }

    @After
    fun tearDown() {
        WritableFactory.createMap = { WritableNativeMap() }
        WritableFactory.createArray = { WritableNativeArray() }
    }

    private fun message(externalUid: String?) = ChatMessage(
        id = "m1",
        conversationId = "c1",
        externalUid = externalUid,
        senderId = null,
        aiRole = "USER",
        turnSeq = 7L,
        renderedContent = buildJsonObject { put("text", "hello") },
        createdAt = "2026-11-18T10:00:00Z",
        sentAt = null
    )

    @Test
    fun `message carries the client message id of a visitor send`() {
        val map = DashXChatBridge.messageToMap(message("in_app_chat:abc"))

        assertEquals("m1", map.getString("id"))
        assertEquals("c1", map.getString("conversationId"))
        assertEquals("in_app_chat:abc", map.getString("externalUid"))
        assertEquals("abc", map.getString("clientMessageId"))
        assertEquals(7.0, map.getDouble("turnSeq"), 0.0)
        assertEquals("hello", map.getMap("renderedContent")?.getString("text"))
        assertEquals(ReadableType.Null, map.getType("senderId"))
        assertEquals(ReadableType.Null, map.getType("sentAt"))
    }

    @Test
    fun `message without a client message id reports null`() {
        val map = DashXChatBridge.messageToMap(message(null))

        assertTrue(map.hasKey("clientMessageId"))
        assertNull(map.getString("clientMessageId"))
    }

    @Test
    fun `loading state`() {
        assertEquals("loading", DashXChatBridge.stateToMap(ConversationState.Loading).getString("status"))
    }

    @Test
    fun `ready state lists messages and paging`() {
        val map = DashXChatBridge.stateToMap(
            ConversationState.Ready(listOf(message(null)), hasOlderMessages = true)
        )

        assertEquals("ready", map.getString("status"))
        assertEquals(1, map.getArray("messages")?.size())
        assertEquals("m1", map.getArray("messages")?.getMap(0)?.getString("id"))
        assertTrue(map.getBoolean("hasOlderMessages"))
        assertEquals(ReadableType.Null, map.getType("streamingReply"))
    }

    @Test
    fun `ready state carries the reply being generated`() {
        val map = DashXChatBridge.stateToMap(
            ConversationState.Ready(
                listOf(message(null)),
                streamingReply = ChatStreamingReply(turnSeq = 8L, text = "Hel", isComplete = false)
            )
        )

        val reply = map.getMap("streamingReply")
        assertEquals(8.0, reply?.getDouble("turnSeq") ?: -1.0, 0.0)
        assertEquals("Hel", reply?.getString("text"))
        assertFalse(reply?.getBoolean("isComplete") ?: true)
    }

    @Test
    fun `error state reports the code and message`() {
        val map = DashXChatBridge.stateToMap(ConversationState.Error(DashXError.SessionEnded()))

        assertEquals("error", map.getString("status"))
        assertEquals("SESSION_ENDED", map.getMap("error")?.getString("code"))
        assertFalse(map.getMap("error")?.getString("message").isNullOrEmpty())
    }

    @Test
    fun `graphql error reports the backend code when there is one`() {
        assertEquals("FORBIDDEN", DashXChatBridge.codeFor(DashXError.GraphQLError("no", "FORBIDDEN")))
        assertEquals("GRAPHQL_ERROR", DashXChatBridge.codeFor(DashXError.GraphQLError("no")))
        assertEquals("NETWORK_ERROR", DashXChatBridge.codeFor(DashXError.NetworkError("offline")))
    }

    @Test
    fun `conversation summary`() {
        val map = DashXChatBridge.conversationToMap(
            ChatConversationSummaryFragment(
                conversationId = "c1",
                category = "support",
                context = ChatConversationSummaryFragment.Context("order", null, "o1", "REF-1", null),
                topic = null,
                status = "ACTIVE",
                title = "Order help",
                lastMessagePreview = "hi",
                lastMessageAt = null,
                lastSenderKind = "agent",
                activityAt = "2026-11-18T10:00:00Z",
                assignedGroups = listOf(ChatConversationSummaryFragment.AssignedGroup("g1", "Support")),
                unreadCount = 3
            )
        )

        assertEquals("c1", map.getString("conversationId"))
        assertEquals("order", map.getMap("context")?.getString("kind"))
        assertEquals("o1", map.getMap("context")?.getString("id"))
        assertEquals(ReadableType.Null, map.getType("topic"))
        assertEquals(ReadableType.Null, map.getType("lastMessageAt"))
        assertEquals("Support", map.getArray("assignedGroups")?.getMap(0)?.getString("name"))
        assertEquals(3, map.getInt("unreadCount"))
    }
}
