# Hateda2md

This is a converter that build separated markdown files using for Jekyll from a Hatena-Diary XML file, which written with Hatena notations. You can set several pre-defined filters and/or can define your original filters.

`Hateda2md`は、はてな記法で書かれたXMLファイルから、Jekyll用のMarkdownファイルを生成するコンバータです。定義済みフィルタを使って、または自身でフィルタを定義して変換を行うことができます。

## Installation

Add this line to your application's Gemfile:

    gem 'hateda2md'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hateda2md

## Usage

    require "Hateda2md"

    mdb = HateDa::MdBuilder.new('hatena-diary.xml')

    # set pre-defined filters
    # 定義済みフィルタをセットする
    mdb.set :title
    mdb.set :subtitle
    mdb.set :link
    mdb.set :amazon
    
    # run converter 
    # 変換を実行する
    mdb.run

    # save converted data to separated markdown files correspond to each entry
    # 変換後のデータを各エントリーに対応した複数のMarkdownファイルに保存する
    mdb.save_to_files

This process create several markdown files under `md` directory.

本処理により`md`ディレクトリ以下に、複数のmarkdownファイルが生成されます。

To set all pre-defined filters, you can call `MdBuilder#pre_defined_filters` or `HateDa::Converter.pre_defined_filters` method.

すべての定義済みフィルタをセットするには、`MdBuilder#pre_defined_filters`または`HateDa::Converter.pre_defined_filters`メソッドを呼びます。

    # read all pre-defined filters
    # すべての定義済みフィルタを呼ぶ
    filters = mdb.pre_defined_filters
    # => [:title, :subtitle, :subsubtitle, :order_list, :unorder_list, :blockquote, :pre, :super_pre, :footnote, :br, :link, :hatebu, :amazon, :youtube, :image, :gist]

    # set all the pre-defined filters
    # すべての定義済みフィルタをセットする
    filters.each { |f| mdb.set f }

You can define your filters using `MdBuilder#filter` method.

`MdBuilder#filter`を使って、独自フィルタを定義できます。

    # define a filter to convert wikipedia hatena tag to a correspond liquid tag
    # はてな記法によるwikipediaタグをliquid tagに変換するフィルタを定義する
    mdb.filter(/\[wikipedia:(.*?)\]/) do |md, st|
      st[:wikipedias] << md[1]
      "{% wikipedia #{md[1]} %}"
    end

`MdBuilder#run` can take parameters for selecting entries to be converted.

`MdBuilder#run`に引数を渡すことで、特定のエントリだけを変換することができます。

    # convert only #20 entry
    # 20番目のエントリだけを変換
    mdb.run(20)

    # convert #100 to last entries
    # 100番から最後のエントリを変換
    mdb.run(100..-1)

    # convert 20 entries from #10
    # 10番から20件を変換
    mdb.run(10,20)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
