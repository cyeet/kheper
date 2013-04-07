class Analyzer < ActiveRecord::Base

  def self.analyze(query)
    frequencies = []
    min = [::Tokenizer.tokenize(query).length - 1, 1].max
    max = ::Tokenizer.tokenize(query).length + 1

    (min..max).each do |len|
      sql = <<-EOD
      SELECT win FROM ch_snippets WHERE ch_en_translation_id IN
      (SELECT ch_en_translation_id FROM en_snippets WHERE win = '#{query}' GROUP BY ch_en_translation_id)
      AND len = #{len}
      GROUP BY win ORDER BY COUNT(*) DESC LIMIT 10
      EOD
      candidates = ::ChSnippet.find_by_sql sql

      candidates.each do |candidate|
        sql = <<-EOD
        SELECT qry, SUM(misses) AS f
        FROM (
          SELECT COALESCE(o1.win,'#{candidate.win}') AS qry,
            COUNT(o1.ch_en_translation_id) + COUNT(o2.ch_en_translation_id) AS misses
          FROM (
            SELECT win, ch_en_translation_id 
            FROM ch_snippets
            WHERE win = '#{candidate.win}'
            GROUP BY win, ch_en_translation_id
          ) o1
          FULL OUTER JOIN (
            SELECT win, ch_en_translation_id 
            FROM en_snippets
            WHERE win IN ('#{query}','#{query},')
            GROUP BY win, ch_en_translation_id
          ) o2
          ON o1.ch_en_translation_id = o2.ch_en_translation_id
          WHERE o1.ch_en_translation_id IS NULL
          OR o2.ch_en_translation_id IS NULL
          GROUP BY o1.win) x
          GROUP BY qry
        EOD

        result = ActiveRecord::Base.connection.execute sql
        frequencies << [result[0]['qry'], result[0]['f'].to_i] if result.first
      end
    end
    frequencies
  end

end
