class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :wins_count, :default => 0
      t.integer :loses_count, :default => 0

      t.timestamps
    end
  end
end
