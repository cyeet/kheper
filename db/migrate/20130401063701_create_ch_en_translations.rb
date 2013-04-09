class CreateChEnTranslations < ActiveRecord::Migration
  def change
    create_table :zh_en_translations do |t|
      t.text :zh, :null => false
      t.text :en, :null => false
      t.text :source, :null => false
    end

    create_table :en_ngrams do |t|
      t.text :text, :null => false
    end

    create_table :zh_ngrams do |t|
      t.text :text, :null => false
    end

    create_table :en_snippets do |t|
      t.text :win, :null => false
      t.text :indow, :null => false    # inverted window
      t.references :zh_en_translation
      t.integer :pos, :null => false  # window starting position from sentence
      t.integer :len, :null => false  # snippet length
    end

    create_table :zh_snippets do |t|
      t.text :win, :null => false
      t.text :indow, :null => false    # inverted window
      t.references :zh_en_translation
      t.integer :pos, :null => false  # window starting position from sentence
      t.integer :len, :null => false  # snippet length
    end

    create_table :zh_analyses do |t|
      t.text :pattern, :null => false
      t.text :translation, :null => false
      t.integer :f, :default => 0
    end

    create_table :en_analyses do |t|
      t.text :pattern, :null => false
      t.text :translation, :null => false
      t.integer :f, :default => 0
    end

    create_table :en_dictionaries do |t|
      t.text :zh, :null => false
      t.text :en, :null => false
      t.integer :len
    end

    create_table :zh_dictionaries do |t|
      t.text :zh, :null => false
      t.text :en, :null => false
      t.integer :len
    end

    add_index :zh_dictionaries, [:zh, :en], :unique => true
    add_index :en_dictionaries, [:en, :zh], :unique => true
  end
end
