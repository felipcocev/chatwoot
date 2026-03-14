class CreateKanbanBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :kanban_boards do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end

    add_index :kanban_boards, [:account_id, :slug], unique: true
    add_index :kanban_boards, [:account_id, :is_default], unique: true, where: "is_default = true"
  end
end
