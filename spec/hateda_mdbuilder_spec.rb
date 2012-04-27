# encoding: UTF-8
require_relative "spec_helper"

describe HateDa::MdBuilder do
  before(:each) do
    @mdb = HateDa::MdBuilder.new('spec/test1.xml')
  end

  context "when initialized with a sample xml" do
    it "create entries property" do
      ->{ @mdb.entries }.should_not raise_error
    end

    it "create entries which are Entry classes" do
      @mdb.entries.each { |entry| entry.class.should eql HateDa::Entry }
    end

    it "set date, body, mdbody, titlefor each entry" do
      body = "*p1*Title\nline1\nline2\nline3\n**SubTitle\nline4"
      a_entry = @mdb.entries.first
      a_entry.ent_date.should eql '2012-03-01'
      a_entry.ent_body.should eql body
      a_entry.ent_mdbody.should eql nil
      a_entry.ent_title.should eql 'hello'
    end
  end

  context "when run for building markdown data for each entry" do
    it "set original body to mdbody of entry with no filter" do
      @mdb.run
      a_entry = @mdb.entries.first
      a_entry.ent_mdbody.should eql a_entry.ent_body
    end

    it "set markdowned body to mdbody of entry" do
      md = "#Title\nline1\nline2\nline3\n##SubTitle\nline4"
      a_entry = @mdb.entries.first
      a_entry.set :title
      a_entry.set :subtitle
      @mdb.run
      a_entry.ent_mdbody.should eql md
    end

    it "set title of entry when it is empty" do
      body = "*p1*Title1\nline1\nline2\nline3\n\n*p2*Title2\nline4\nline5"
      a_entry, b_entry = @mdb.entries.take(2)
      a_entry.set :title
      b_entry.set :title
      @mdb.run
      a_entry.ent_title.should eql 'hello'
      b_entry.ent_title.should eql 'Title1'
    end
  end

  context "set filter to all entries at once" do
    before(:each) do
      @mdb2 = HateDa::MdBuilder.new('spec/test2.xml')
    end

    it "set title with set method" do
      md1 = "#Title\nline1\nline2\nline3\n**SubTitle\nline4"
      md2 = "#Title1\nline1\nline2\nline3\n\n#Title2\nline4\nline5"
      @mdb2.set :title
      @mdb2.run
      entries = @mdb2.entries.zip([md1, md2])
      entries.each do |ent, md|
        ent.ent_mdbody.should eql md
      end
    end

    it "set title & subtitle with filter method" do
      md1 = "#Title\nline1\nline2\nline3\n##SubTitle\nline4"
      md2 = "#Title1\nline1\nline2\nline3\n\n#Title2\nline4\nline5"
      @mdb2.filter(/\*p?\d+\*(.*)$/) do |md, st|
        st[:titles] << md[1]
        "##{md[1]}"
      end
      @mdb2.filter(/^\*\*((?!\*).*)$/) do |md, st|
        st[:subtitles] << md[1]
        "###{md[1]}"
      end
      @mdb2.run
      entries = @mdb2.entries.zip([md1, md2])
      entries.each do |ent, md|
        ent.ent_mdbody.should eql md
      end
    end
  end
end