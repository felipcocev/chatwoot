module Kanban
  class SetupDefaultBoardService
    DEFAULT_COLUMNS = [
      { name: 'Novo', slug: 'novo' },
      { name: 'Em atendimento', slug: 'em-atendimento' },
      { name: 'Proposta', slug: 'proposta' },
      { name: 'Fechado', slug: 'fechado' }
    ].freeze

    def self.call(account)
      new(account).call
    end

    def initialize(account)
      @account = account
    end

    def call
      board = @account.kanban_boards.default_board.first

      return board if board.present?

      ActiveRecord::Base.transaction do
        board = @account.kanban_boards.create!(
          name: 'Kanban',
          slug: 'kanban',
          is_default: true
        )

        DEFAULT_COLUMNS.each_with_index do |column, index|
          board.kanban_columns.create!(
            name: column[:name],
            slug: column[:slug],
            position: index
          )
        end

        board
      end
    end
  end
end
