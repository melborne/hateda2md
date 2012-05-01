# encoding: UTF-8

require_relative "spec_helper"

include HateDa::Converter

describe HateDa::Converter do
  context "pass a text to to_md method" do
    before(:each) do
      @hdtext = <<EOS
*p1*title1
content1
content2
**subtitle1
content3
content4
**subtitle2
contetn5
*123*title2

EOS
    end
    
    after(:each) do
      clear_filter
    end
    
    it "should not change the text when filter is empty" do
      hdtext = "*p1*title1\ncontent"
      to_md(hdtext).should eql hdtext
    end

    it "should raise error when set non-defined tags" do
      ->{ set(:hello) }.should raise_error(HateDa::Converter::NoFilterError)
    end

    context "header" do
      it "change a header" do
        hdtext = "*p1*title1\ncontent"
        md     = "#title1\ncontent"
        set :header
        to_md(hdtext).should eql md
        stocks[:titles].should eql ['title1']
      end

      it "change a header by h3" do
        hdtext = "*p1*title1\ncontent"
        md     = "###title1\ncontent"
        set :header, :h3
        to_md(hdtext).should eql md
      end

      it "change several headers with :title(alias of :header)" do
        hdtext = "*123*title1\ncontent1\n*p3*title2\ncontent2"
        md     = "#title1\ncontent1\n#title2\ncontent2"
        set :title
        to_md(hdtext).should eql md
        stocks[:titles].should eql ['title1', 'title2']
      end

      it "change a subheader" do
        hdtext = "**subtitle1\ncontent**2"
        md     = "##subtitle1\ncontent**2"
        set :subheader
        to_md(hdtext).should eql md
      end

      it "change subheaders with :subtitle(alias of :subheader)" do
        hdtext = "**subtitle1\ncontent1\n**subtitle2\ncontent**2"
        md     = "##subtitle1\ncontent1\n##subtitle2\ncontent**2"
        set :subtitle
        to_md(hdtext).should eql md
      end

      it "change a subsubheader" do
        hdtext = "***subsubtitle1\ncontent***2"
        md     = "###subsubtitle1\ncontent***2"
        set :subsubheader
        to_md(hdtext).should eql md
      end

      it "change mixed title cases1" do
        hdtext = "*p1*title\n***sstitle\ncontent\n**stit***le\nconten**t\n***sstitle"
        set :subheader
        md = "*p1*title\n***sstitle\ncontent\n##stit***le\nconten**t\n***sstitle"
        to_md(hdtext).should eql md
      end

      it "change mixed title cases2" do
        hdtext = "*p1*title\n***sstitle\ncontent\n**stit***le\nconten**t\n***sstitle"
        set :subsubtitle
        md = "*p1*title\n###sstitle\ncontent\n**stit***le\nconten**t\n###sstitle"
        to_md(hdtext).should eql md
      end

      it "change mixed title cases3" do
        hdtext = "*p1*title\n***sstitle\ncontent\n**stit***le\nconten**t\n***sstitle"
        set :title
        set :subtitle
        md = "#title\n***sstitle\ncontent\n##stit***le\nconten**t\n***sstitle"
        to_md(hdtext).should eql md
      end

      it "change mixed title cases4" do
        hdtext = "*p1*title\n***sstitle1\ncontent\n**stit***le\nconten**t\n***sstitle2"
        set :subtitle
        set :subsubtitle
        md = "*p1*title\n###sstitle1\ncontent\n##stit***le\nconten**t\n###sstitle2"
        to_md(hdtext).should eql md
      end
    end
    
    context "list" do
      it "change ordered list" do
        hdtext = "+item1\n+item2\n+item3"
        set :order_list
        md     = "1. item1\n1. item2\n1. item3"
        to_md(hdtext).should eql md
      end

      it "change nested ordered list" do
        hdtext = <<EOS
+item1
++item1-1
++item1-2
+item2
+item3
++item3-1
+++item3-1-1
+++item3-1-2
++item3-2
EOS
        
        md = <<EOS
1. item1
    1. item1-1
    1. item1-2
1. item2
1. item3
    1. item3-1
        1. item3-1-1
        1. item3-1-2
    1. item3-2
EOS
        set :order_list
        to_md(hdtext).should eql md
      end

      it "change unordered list" do
        hdtext = "-item1\n-item2\n-item3"
        set :unorder_list
        md     = "- item1\n- item2\n- item3"
        to_md(hdtext).should eql md
      end

      it "change nested unordered list" do
        hdtext = <<EOS
-item1
--item1-1
--item1-2
-item2
-item3
--item3-1
---item3-1-1
---item3-1-2
--item3-2
EOS

        md = <<EOS
- item1
    - item1-1
    - item1-2
- item2
- item3
    - item3-1
        - item3-1-1
        - item3-1-2
    - item3-2
EOS
        set :unorder_list
        to_md(hdtext).should eql md
      end


    end

    context "pre" do
      it "change blockquote '>> <<' to '>'" do
        hdtext = <<EOS
>>
blockquoted
blockquoted
blockquoted
<<
EOS
      md = <<EOS

> blockquoted
> blockquoted
> blockquoted

EOS
        set :blockquote
        to_md(hdtext).should eql md
      end

      it "change pre '>|' to 4 spaces" do
        hdtext = <<EOS
>|
blockquoted
blockquoted
blockquoted
|<
EOS
      md = <<EOS

    blockquoted
    blockquoted
    blockquoted

EOS
        set :pre
        to_md(hdtext).should eql md
      end

      it "change super_pre '>|type|' to highlight tag" do
        hdtext = <<EOS
>|ruby|
def hello(name)
  "hello, \#{name}!"
end
||<
EOS
      md = <<EOS
{% highlight ruby %}
def hello(name)
  "hello, \#{name}!"
end
{% endhighlight %}
EOS
        set :super_pre
        to_md(hdtext).should eql md
      end
    end

    context "footnote" do
      it "change '(())' to footnote tag" do
        hdtext = "sentence((aaa)), sentence\nsentence((bbb))"
        md     = "sentence{% fn_ref 1 %}, sentence\nsentence{% fn_ref 2 %}"
        set :footnote
        to_md(hdtext).should eql md
        stocks[:footnotes].should eql ["{% fn aaa %}", "{% fn bbb %}"]
      end
    end

    context "br" do
      it "change '\n\n' to <br/>" do
        hdtext = "content\n\ncontent\ncontent\n\ncontent"
        md     = "content\ncontent\ncontent\ncontent"
        set :br
        to_md(hdtext).should eql md
      end
    end

    context "link" do
      it "change a url to a link" do
        hdtext = <<EOS
sentence
http://www.abc.com
sentence http://www.efg.com/123_456 sentence
sentence(https://www.xyz.co.jp),sen..
EOS
        md     = <<EOS
sentence
[http://www.abc.com](http://www.abc.com)
sentence [http://www.efg.com/123_456](http://www.efg.com/123_456) sentence
sentence([https://www.xyz.co.jp](https://www.xyz.co.jp)),sen..
EOS
        set :link
        to_md(hdtext).should eql md
      end

      it "change a url with title to a link" do
        hdtext = <<EOS
*p1*Title X
sentence
[http://www.abc.com/:title]
sentence [http://www.efg.com/123_456:title=Title1] sentence
sentence([https://www.xyz.co.jp/:title=Title no.2]),sen..
http://mmm.ff.co.jp/
EOS
        md     = <<EOS
#Title X
sentence
[Title X](http://www.abc.com/)
sentence [Title1](http://www.efg.com/123_456) sentence
sentence([Title no.2](https://www.xyz.co.jp/)),sen..
[http://mmm.ff.co.jp/](http://mmm.ff.co.jp/)
EOS
        set :title
        set :link
        to_md(hdtext).should eql md
      end
    end
  
    context "amazon" do
      it "change amazon detail link to amazon tag" do
        hdtext = "[asin:4797356014:detail]"
        md     = "{{ '4797356014' | amazon_medium_image }}\n{{ '4797356014' | amazon_link }} by {{ '4797356014' | amazon_authors }}"
        set :amazon
        to_md(hdtext).should eql md
      end

      it "change amazon image link to amazon tag" do
        hdtext = "[asin:4797356014:image]"
        md     = "{{ '4797356014' | amazon_medium_image }}"
        set :amazon
        to_md(hdtext).should eql md
      end
    end
  
    context "youtube" do
      it "change youtube link to youtube tag" do
        hdtext = "[http://www.youtube.com/watch?v=oDSigzI6YKw:movie]"
        md     = "{% youtube oDSigzI6YKw %}"
        set :youtube
        to_md(hdtext).should eql md
      end
    end

    context "fotolife" do
      it "change fotolife link to image tag" do
        hdtext = "[f:id:keyesberry:20110209105103p:image]"
        md     = "\n![image](http://img.f.hatena.ne.jp/images/fotolife/k/keyesberry/20110209/20110209105103.png)\n"
        set :image
        to_md(hdtext).should eql md
      end
    end

    context "gist" do
      it "change gist link to gist tag" do
        hdtext = %{<script src="https://gist.github.com/2177656.js?file=gsub_filter.rb"></script>}
        md     = "{% gist 2177656 gsub_filter.rb %}"
        set :gist
        to_md(hdtext).should eql md
      end
    end

    context "hatebu" do
      it "change hatena bookmark link to gist tag" do
        hdtext = %{[http://d.hatena.ne.jp/keyesberry/20090318/p1:bookmark]}
        md     = "{% hatebu http://d.hatena.ne.jp/keyesberry/20090318/p1 %}"
        set :hatebu
        to_md(hdtext).should eql md
      end
    end
  end
end

