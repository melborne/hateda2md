# encoding: UTF-8
require "gsub_filter"
require "uri"

module HateDa::Converter
  class NoFilterError < StandardError; end
  
  def set(item, *args)
    unless HateDa::Converter.pre_defined_filters(true).include?(item)
      raise NoFilterError, "#{item} does not pre-defined."
    end
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
  
  def filter(pattern, opt={}, &replace)
    @gf ||= GsubFilter.new
    @gf.filter(pattern, opt, &replace)
  end

  def self.pre_defined_filters(aliases=false)
    als = aliases ? [] : [:header, :subheader, :subsubheader, :ul, :ol]
    private_instance_methods(false) - [:SYM] - als
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
    filter(/^#{SYM(h)}.*$/, global:false) do |md, st|
      st[:titles].size == 1 ? '' : md.to_s
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
      "\n" + md[1].gsub(/^.*$/, '> \0')
    end
  end

  def pre
    filter(/^>\|\n(.*?)^\|<$/m) do |md|
      "\n" + md[1].gsub(/^.*$/, '    \0')
    end
  end

  def super_pre
    filter(/^>\|(\w+)?\|/) do |md|
      lang = md[1] || "bash"
      "{% highlight #{lang} %}"
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
    url_r = URI.regexp(['http', 'https'])

    filter(/(?:(?<=[ \(])|^)#{url_r}(?!\s%})(?:(?=[ \)])|$)/) do |md|
      "[#{md}](#{md})"
    end

    filter(/\[(#{url_r})(?::title=?(.*?))\]/) do |md|
      t = md.captures.last
      title = t.empty? ? ((st = stocks[:titles]) ? st.first : 'link') : t
      "[#{title}](#{md[1]})"
    end
  end

  def hatebu(liquid=true)
    url_r = URI.regexp(['http', 'https'])
    filter(/\[(#{url_r}):bookmark\]/) do |md|
      if liquid
        "{% hatebu #{md[1]} %}"
      else
        hatebu_html(md[1])
      end
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

  def youtube(liquid=true)
    filter(/[\(\[]?\s*https?:\/\/.*?youtube.*?\?v=([a-zA-Z0-9_-]+):movie\s*[\]\)]?/) do |md|
      if liquid
        "{% youtube #{md[1]} %}"
      else
        youtube_html(md)
      end
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

  def gist(liquid=true)
    host = %r{https?://gist.github.com/}
    filter(/<script src=\"#{host}(\d+)\.js\?file=(.*?)\"><\/script>/) do |md|
      if liquid
        "{% gist #{md[1]} #{md[2]} %}"
      else
        gist_html(md)
      end
    end
  end

  def hatebu_html(md)
    url, title = md.to_s.match(/(https?:\/\/\S+)(.*)/){ [$1, $2] }
    bm_url = %{<a href="http://b.hatena.ne.jp/entry/#{url}" class="http-bookmark" target="_blank"><img src="http://b.hatena.ne.jp/entry/image/#{url}" alt="" class="http-bookmark"></a>}

    unless title.nil?
      %{<a href="#{url}" target="_blank">#{title.strip} </a>} + bm_url
    else
      bm_url
    end
  end

  def gist_html(md)
    %{<div><script src="https://gist.github.com/#{md[1]}.js?file=#{md[2]}"></script></div>%}
  end

  def youtube_html(md)
    %{<iframe width="560" height="420" src="http://www.youtube.com/embed/#{md[1]}?color=white&theme=light"></iframe>}
  end
end
