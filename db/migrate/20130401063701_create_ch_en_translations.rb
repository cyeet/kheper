class CreateChEnTranslations < ActiveRecord::Migration
  def change
    create_table :ch_en_translations do |t|
      t.text :ch, :null => false
      t.text :en, :null => false
      t.text :source, :null => false
    end

    create_table :en_ngrams do |t|
      t.text :text, :null => false
    end

    create_table :ch_ngrams do |t|
      t.text :text, :null => false
    end

    create_table :en_snippets do |t|
      t.text :window, :null => false
      t.text :indow, :null => false    # inverted window
      t.text :hash, :null => false     # segment hash
      t.integer :length, :null => false  # snippet length
    end

    create_table :ch_snippets do |t|
      t.text :window, :null => false
      t.text :indow, :null => false    # inverted window
      t.references :ch_en_translation
      t.integer :pos, :null => false  # window starting position from sentence
      t.integer :len, :null => false  # snippet length
    end

    create_table :ch_analyses do |t|
      t.text :pattern, :null => false
      t.text :translation, :null => false
      t.integer :f, :default => 0
      t.references :ch_en_translation
    end

    create_table :ch_analyses do |t|
      t.text :pattern, :null => false
      t.text :translation, :null => false
      t.integer :f, :default => 0
    end

    create_table :ch_en_dictionaries do |t|
      t.text :ch, :null => false
      t.text :en, :null => false
    end
  end
end
