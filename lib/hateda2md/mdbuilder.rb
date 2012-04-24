# encoding: UTF-8
require "nokogiri"

class HateDa::MdBuilder
  attr_reader :entries
  def initialize(path)
    @entries = build_entries(path)
  end
  
  def build_entries(filepath)
    xml = Nokogiri::XML(open filepath)
    xml.search('day').map do |ent|
      date = ent.attributes['date'].value
      body = ent.css('body').text.strip
      mdbody = nil
      title = ent.attributes['title'].value
      HateDa::Entry[date, body, mdbody, title]
    end
  end
  
  def run
    @entries.each do |entry|
      md = entry.to_md(entry.ent_body)
      entry.ent_title = get_title(entry) if entry.ent_title.empty?
      entry.ent_mdbody = md
    end
  end

  private
  def get_title(entry)
    entry.stocks[:titles].first || 'notitle'
  end
end

