class KanbanColumn < ApplicationRecord
  belongs_to :kanban_board
  has_many :kanban_cards, -> { order(position: :asc, id: :asc) }, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :kanban_board_id }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
