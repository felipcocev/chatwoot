class KanbanBoard < ApplicationRecord
  belongs_to :account

  has_many :kanban_columns, -> { order(position: :asc, id: :asc) }, dependent: :destroy
  has_many :kanban_cards, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :account_id }

  scope :default_board, -> { where(is_default: true) }
end
