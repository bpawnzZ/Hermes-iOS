import Testing
@testable import HermesMobile

struct HermesMobileTests {

    @Test func messageCreationDefaultsToSentStatus() async throws {
        let message = Message(sender: .user, content: "Hello Hermes")
        #expect(message.sender == .user)
        #expect(message.content == "Hello Hermes")
        #expect(message.status == .sent)
    }

    @Test func conversationPreviewTextShowsLastMessage() async throws {
        let messages = [
            Message(sender: .hermes, content: "First message"),
            Message(sender: .user, content: "Second message"),
        ]
        let conversation = Conversation(title: "Test", messages: messages)
        #expect(conversation.previewText == "Second message")
        #expect(conversation.lastMessage?.sender == .user)
    }

    @Test func emptyConversationShowsPlaceholderPreview() async throws {
        let conversation = Conversation(title: "Empty")
        #expect(conversation.previewText == "No messages yet")
        #expect(conversation.lastMessage == nil)
    }

    @Test func permissionTypeHasDistinctColorsAndIcons() async throws {
        let types = PermissionType.allCases

        // Assert the real invariant rather than a hardcoded count: every
        // permission must be visually distinguishable. Using the case count
        // as the expected value keeps this from going stale when a permission
        // is added, while still catching a duplicated icon or colour.
        let icons = Set(types.map(\.displayIcon))
        #expect(
            icons.count == types.count,
            "Each permission type should have a unique icon (got \(icons.count) unique icons for \(types.count) types)"
        )

        let colors = Set(types.map { String(describing: $0.displayColor) })
        #expect(
            colors.count == types.count,
            "Each permission type should have a unique colour (got \(colors.count) unique colours for \(types.count) types)"
        )

        for type in types {
            #expect(!type.displayLabel.isEmpty)
            #expect(!type.explanation.isEmpty)
        }
    }

    @Test func inboxItemTypeVisualIdentityIsComplete() async throws {
        for itemType in InboxItemType.allCases {
            #expect(!itemType.displayLabel.isEmpty)
            #expect(!itemType.displayIcon.isEmpty)
        }
    }
}
