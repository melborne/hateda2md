# encoding: UTF-8
require "../lib/hateda2md"

mdb = HateDa::MdBuilder.new('example.xml')

filters = mdb.pre_defined_filters
filters.each { |f| mdb.set f }
mdb.run(0..200)
mdb.save_to_files
