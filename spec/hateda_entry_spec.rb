# encoding: UTF-8
require_relative 'spec_helper'

describe HateDa::Entry do
  context "when created" do
    context "without argument" do
      before(:each) do
        @entry = HateDa::Entry.new
      end

      it "should have ent_date, ent_title, ent_body, ent_mdbody property" do
        ->{ @entry.ent_date }.should_not raise_error
        ->{ @entry.ent_title }.should_not raise_error
        ->{ @entry.ent_body }.should_not raise_error
        ->{ @entry.ent_mdbody }.should_not raise_error
      end
    end

    context "with data" do
      before(:each) do
        @date, @body, @mdbody, @title = '2012-04-21', "hello\nfriend!", "", "hello"
        @entry = HateDa::Entry.new(@date, @body, @mdbody, @title)
      end

      it "should return data" do
        @entry.ent_date.should eql @date
        @entry.ent_body.should eql @body
        @entry.ent_mdbody.should eql @mdbody
        @entry.ent_title.should eql @title
      end
    end
  end
end

