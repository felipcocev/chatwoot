class CreateKanbanColumns < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_columns do |t|
      t.references :kanban_board, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :kanban_columns, [:kanban_board_id, :slug], unique: true
    add_index :kanban_columns, [:kanban_board_id, :position]
  end
end
