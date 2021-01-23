class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :name
      t.text :url
      t.text :image_url
      t.integer :image_width
      t.integer :image_height
      t.string :description
      t.string :provider_name
      t.datetime :date_published

      t.timestamps
    end
  end
end
