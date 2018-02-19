class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|

      t.timestamps
    end
  end
end
