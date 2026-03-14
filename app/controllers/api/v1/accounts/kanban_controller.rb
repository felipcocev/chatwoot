class Api::V1::Accounts::KanbanController < Api::V1::Accounts::BaseController
  before_action :set_board, only: [:show, :move_card]
  before_action :set_card, only: [:move_card]

  def show
    render json: serialized_board
  end

  def move_card
    target_column = @board.kanban_columns.find(params.require(:kanban_column_id))
    target_position = params[:position].to_i

    ActiveRecord::Base.transaction do
      old_column_id = @card.kanban_column_id

      if old_column_id == target_column.id
        reorder_within_same_column(@card, target_position)
      else
        move_to_another_column(@card, target_column, target_position)
        normalize_column_positions(old_column_id)
      end

      normalize_column_positions(target_column.id)
    end

    render json: serialized_board
  end

  private

  def set_board
    @board = Kanban::SetupDefaultBoardService.call(Current.account)
  end

  def set_card
    @card = @board.kanban_cards.find(params[:id])
  end

  def serialized_board
    {
      id: @board.id,
      name: @board.name,
      slug: @board.slug,
      columns: @board.kanban_columns.order(position: :asc, id: :asc).map do |column|
        {
          id: column.id,
          name: column.name,
          slug: column.slug,
          position: column.position,
          cards: column.kanban_cards
                       .order(position: :asc, id: :asc)
                       .includes(conversation: :contact)
                       .map do |card|
            conversation = card.conversation
            contact = conversation.contact

            {
              id: card.id,
              position: card.position,
              conversation_id: conversation.id,
              display_id: conversation.display_id,
              status: conversation.status,
              inbox_id: conversation.inbox_id,
              account_id: conversation.account_id,
              assignee_id: conversation.assignee_id,
              team_id: conversation.team_id,
              created_at: conversation.created_at,
              last_activity_at: conversation.last_activity_at,
              contact: {
                id: contact&.id,
                name: contact&.name,
                email: contact&.email,
                phone_number: contact&.phone_number
              }
            }
          end
        }
      end
    }
  end

  def reorder_within_same_column(card, target_position)
    cards = @board.kanban_cards
                  .where(kanban_column_id: card.kanban_column_id)
                  .order(position: :asc, id: :asc)
                  .to_a

    cards.reject! { |item| item.id == card.id }
    target_position = [[target_position, 0].max, cards.length].min
    cards.insert(target_position, card)

    cards.each_with_index do |item, index|
      item.update!(position: index, kanban_column_id: card.kanban_column_id)
    end
  end

  def move_to_another_column(card, target_column, target_position)
    target_cards = @board.kanban_cards
                         .where(kanban_column_id: target_column.id)
                         .order(position: :asc, id: :asc)
                         .to_a

    target_cards.reject! { |item| item.id == card.id }
    target_position = [[target_position, 0].max, target_cards.length].min

    card.kanban_column_id = target_column.id
    target_cards.insert(target_position, card)

    target_cards.each_with_index do |item, index|
      item.update!(position: index, kanban_column_id: target_column.id)
    end
  end

  def normalize_column_positions(column_id)
    @board.kanban_cards
          .where(kanban_column_id: column_id)
          .order(position: :asc, id: :asc)
          .each_with_index do |card, index|
      next if card.position == index

      card.update!(position: index)
    end
  end
end
