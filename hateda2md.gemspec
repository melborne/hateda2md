# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hateda2md/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["kyoendo"]
  gem.email         = ["postagie@gmail.com"]
  gem.description   = %q{Convert Hatena-Diary XML file to Markdown files for Jekyll}
  gem.summary       = %q{
    This is a converter that build separated markdown files using for Jekyll from a Hatena-Diary XML file, which written with Hatena notations. You can set several pre-defined filters or can define your original filters.
    }.strip
  gem.homepage      = "https://github.com/melborne/hateda2md"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hateda2md"
  gem.require_paths = ["lib"]
  gem.version       = Hateda2md::VERSION
  gem.required_ruby_version = '>=1.9.2'
  gem.add_development_dependency 'rspec'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'gsub_filter'
end
