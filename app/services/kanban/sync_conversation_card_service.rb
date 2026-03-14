module Kanban
  class SyncConversationCardService
    def self.call(conversation)
      new(conversation).call
    end

    def initialize(conversation)
      @conversation = conversation
      @account = conversation.account
    end

    def call
      return unless @account.present?

      board = Kanban::SetupDefaultBoardService.call(@account)
      first_column = board.kanban_columns.order(position: :asc, id: :asc).first
      return unless first_column.present?

      existing_card = board.kanban_cards.find_by(conversation_id: @conversation.id)
      return existing_card if existing_card.present?

      position = board.kanban_cards.where(kanban_column_id: first_column.id).count

      board.kanban_cards.create!(
        kanban_column: first_column,
        conversation: @conversation,
        position: position
      )
    end
  end
end
