class KanbanCard < ApplicationRecord
  belongs_to :kanban_board
  belongs_to :kanban_column
  belongs_to :conversation

  validates :conversation_id, uniqueness: { scope: :kanban_board_id }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
