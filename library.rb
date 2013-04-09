MAX_SEGMENT_LENGTH_EN = 7
MAX_SEGMENT_LENGTH_CH = 7

CHINESE_ENCODINGS = %w(UTF-8 GB2312 GB12345 CP51932 CP951 CP950 GB1988 GBK GB18030 CP949 Big5-UAO Big5-HKSCS Big5)

class EnglishPhrase < ActiveRecord::Base
end

class ZhEnTranslation < ActiveRecord::Base
  has_many :en_analyses
  has_many :zh_analyses
  validates_uniqueness_of :en, :scope => :source
end

class EnAnalysis < ActiveRecord::Base
  belongs_to :zh_en_translation
end

class ZhAnalysis < ActiveRecord::Base
  belongs_to :zh_en_translation
end

class ZhSnippet < ActiveRecord::Base
  belongs_to :zh_en_translation
end

class ZhDictionary < ActiveRecord::Base
end

class EnDictionary < ActiveRecord::Base
end
