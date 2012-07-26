class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :ended, :default => false

      t.timestamps
    end
  end
end
