# encoding: UTF-8
require "nokogiri"
class String
  def ~
    mergin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{mergin}}/, '')
  end

  def to_nil
    self.empty? ? nil : self
  end
end

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

  def set(item, *args)
    entries.each { |ent| ent.set item, *args }
  end
  
  def filter(pattern, opt={}, &replace)
    entries.each { |ent| ent.filter(pattern, opt, &replace) }
  end

  def pre_defined_filters(alias_flag=false)
    HateDa::Converter.pre_defined_filters(alias_flag)
  end
  
  def run(*range)
    range = [0..-1] if range.empty?
    entries[*range].map do |entry|
      md = entry.to_md(entry.ent_body)
      entry.ent_title = get_title(entry) if entry.ent_title.empty?
      entry.ent_mdbody = md
    end
  end

  def save_to_files(dir='md', ext='md')
    md_entries = entries.select { |ent| ent.ent_mdbody }
    unless md_entries.empty?
      Dir.mkdir(dir) unless Dir.exist?(dir)
      md_entries.each do |ent|
        path = "#{dir}/#{ent.ent_date}-#{title_for_file(ent.ent_title)}.#{ext}"
        File.open(path, 'w') do |f|
          f.puts header(ent.ent_title, ent.ent_date)
          f.puts ent.ent_mdbody
          f.puts footnotes(ent.stocks[:footnotes]) unless ent.stocks[:footnotes].empty?
        end
      end
    end
  rescue => e
    print "class => #{e.class}\nmessage => #{e.message}\nbacktrace => #{e.backtrace}\n"
  end

  private
  def get_title(entry)
    entry.stocks[:titles].first || 'notitle'
  end

  def title_for_file(title)
    title.scan(/\w+/).join('-').to_nil || 'notitle'
  end

  def header(title, date)
    title = title.gsub(/['"`]/, '')
    ~<<-EOS
    ---
    layout: post
    title: "#{title}"
    date: #{date}
    comments: true
    categories:
    tags:
    published: true
    ---

    EOS
  end

  def footnotes(fnotes)
    notes = fnotes.map { |note| "#{note}" }.join("\n    ")
    ~<<-EOS

    {% footnotes %}
    #{notes}
    {% endfootnotes %}
    EOS
  end
end

