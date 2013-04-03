class CreateChEnTranslations < ActiveRecord::Migration
  def change
    create_table :ch_en_translations do |t|
      t.text :ch, :null => false
      t.text :en, :null => false
      t.string :source, :null => false
    end

    create_table :en_analyses do |t|
      t.string :window, :null => false
      t.string :indow, :null => false
      t.string :source, :null => false
    end

    create_table :ch_analyses do |t|
      t.string :window, :null => false
      t.string :indow, :null => false
      t.string :source, :null => false
    end
  end
end
