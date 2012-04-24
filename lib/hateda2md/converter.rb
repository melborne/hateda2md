# encoding: UTF-8
require "gsub_filter"
require "uri"

module HateDa::Converter
  def set(item, *args)
    send item, *args
  end
  
  def to_md(hdtext)
    (@gf ||= GsubFilter.new).run(hdtext)
  end

  def clear_filter
    @gf.filters.clear if @gf
  end

  def stocks
    @gf.stocks if @gf
  end
  
  private
  def SYM(key)
    {h1:'#',h2:'##',h3:'###',h4:'####',h5:'#####'}[key]
  end

  def title(h=:h1)
    filter(/\*p?\d+\*(.*)$/) do |md, st|
      st[:titles] << md[1]
      "#{SYM(h)}#{md[1]}"
    end
  end
  alias :header :title

  def subtitle(h=:h2)
    filter(/^\*\*((?!\*).*)$/) do |md, st|
      st[:subtitles] << md[1]
      "#{SYM(h)}#{md[1]}"
    end
  end
  alias :subheader :subtitle

  def subsubtitle(h=:h3)
    filter(/^\*\*\*((?!\*).*)$/) do |md, st|
      st[:subsubtitles] << md[1]
      "#{SYM(h)}#{md[1]}"
    end
  end
  alias :subsubheader :subsubtitle

  def order_list
    filter(/^(\++)\s*(.*?)$/) do |md, st|
      st[:order_lists] << md[2]
      shift = (" " * 4) * (md[1].size-1)
      "#{shift}1. #{md[2]}"
    end
  end
  alias :ol :order_list
  
  def unorder_list
    filter(/^(\-+)\s*(.*?)$/) do |md, st|
      st[:unorder_lists] << md[2]
      shift = (" " * 4) * (md[1].size-1)
      "#{shift}- #{md[2]}"
    end
  end
  alias :ul :unorder_list

  def blockquote
    filter(/^>>\n(.*?)^<<$/m) do |md|
      "\n" + md[1].lines.map { |line| "> #{line}" }.join
    end
  end

  def pre
    filter(/^>\|\n(.*?)^\|<$/m) do |md|
      "\n" + md[1].lines.map { |line| "    #{line}" }.join
    end
  end

  def super_pre
    filter(/^>\|(\w+)?\|/) do |md|
      lang = md[1].empty? ? '' : "#{md[1]} "
      "{% highlight #{lang}%}"
    end

    filter(/^\|\|</) { "{% endhighlight %}" }
  end

  def footnote
    filter(/\(\((.*?)\)\)/) do |md, st|  
        "{% fn_ref #{st[:footnotes].size+1} %}"
        .tap { st[:footnotes] << "{% fn #{md[1]} %}" }
    end
  end

  def br
    filter("\n\n") { "\n" }
  end

  def link
    url = URI.regexp(['http', 'https'])

    filter(/(?:(?<=[ \(])|^)#{url}(?:(?=[ \)])|$)/) do |md|
      "[#{md}](#{md})"
    end

    filter(/\[(#{url})(?::title=?(.*))\]/) do |md|
        t = md.captures.last
        title = t.empty? ? ((st = stocks[:titles]) ? st.first : 'link') : t
        "[#{title}](#{md[1]})"
    end
  end

  def amazon
    filter(/\[?(?:isbn|asin):(\w+)(?::(title|detail|image))?\]?/i) do |md|  
        case md[2]
        when 'title'
          "{{ '#{md[1]}' | amazon_link }}"
        when 'image'
          "{{ '#{md[1]}' | amazon_medium_image }}"
        when 'detail'
          "{{ '#{md[1]}' | amazon_medium_image }}\n{{ '#{md[1]}' | amazon_link }} by {{ '#{md[1]}' | amazon_authors }}"
        else
          "{{ '#{md[1]}' | amazon_medium_image }}"
        end
    end
  end

  def youtube
    filter(/[\(\[]?\s*https?:\/\/.*?youtube.*?\?v=([a-zA-Z0-9_-]+):movie\s*[\]\)]?/) do |md|
      "{% youtube #{md[1]} %}"
    end
  end

  def image
    filter(/\[?f:id:(.*?):(\d+)(\w):image.*?\]?/) do |md|
      m1, m2, m3 = md.captures
      ft = %w(png jpg bmp gif).detect { |e| e[/^#{m3}/] }
      host = "http://img.f.hatena.ne.jp/images/fotolife"
      %{\n![image](#{host}/#{m1[0]}/#{m1}/#{m2[0,8]}/#{m2}.#{ft})\n}
    end
  end

  def gist
    host = %r{https?://gist.github.com/}
    filter(/<script src=\"#{host}(\d+)\.js\?file=(.*?)\"><\/script>/) do |md|
       "{% gist #{md[1]} #{md[2]} %}"
    end
  end
  
  def filter(pattern, opt={}, &replace)
    @gf ||= GsubFilter.new
    @gf.filter(pattern, opt, &replace)
  end
  
end