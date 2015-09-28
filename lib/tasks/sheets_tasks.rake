require 'fileutils'

namespace :sheets do

  desc "Install Sheets to your database"
  task :install do
    puts "Installing Sheets\n"

    # install migrations
    Rake::Task['sheets_engine:install:migrations'].execute

    puts "\n => Adding javascripts to application.js"

    # prepare for adding handsontable to the application javascripts
    tempfile=Tempfile.new("javascripts")
    path = Rails.root.to_s + "/app/assets/javascripts/application.js"
    f=File.new(path)

    # assume javascripts are not required yet
    h=n=l=b=r=false

    # insert javascript requirements once, before the require tree line
    f.each do |line|
      h = true if line=~/handsontable.dist.handsontable.full/
      l = true if line=~/lodash.lodash/
      u = true if line=~/underscore\.string.underscore\.string/
      n = true if line=~/numeraljs.numeral/
      nl = true if line=~/numeraljs.languages/
      njs = true if line=~/numericjs.numeric/
      m = true if line=~/js\-md5.md5/
      j = true if line=~/jstat.jstat/
      f = true if line=~/formulajs.formula/
      rjp = true if line=~/ruleJS.parser/
      rjs = true if line=~/ruleJS.ruleJS/
      hf = true if line=~/handsontable.formula/
      b = true if line=~/best_in_place/
      r = true if line=~/reveal/

      if line=~/require_tree/
        tempfile<<"//= require handsontable/dist/handsontable.full\n" unless h
        tempfile<<"//= require handsontable/dist/ruleJS/lodash/lodash\n" unless l
        tempfile<<"//= require handsontable/dist/ruleJS/underscore.string/underscore.string\n" unless u
        tempfile<<"//= require numeraljs/numeral\n" unless n
        tempfile<<"//= require numeraljs/languages\n" unless nl
        tempfile<<"//= require handsontable/dist/ruleJS/numericjs/numeric\n" unless njs
        tempfile<<"//= require handsontable/dist/ruleJS/js-md5/md5\n" unless m
        tempfile<<"//= require handsontable/dist/ruleJS/jstat/jstat\n" unless j
        tempfile<<"//= require handsontable/dist/ruleJS/formulajs/formula\n" unless f
        tempfile<<"//= require handsontable/dist/ruleJS/parser\n" unless rjp
        tempfile<<"//= require handsontable/dist/ruleJS/ruleJS\n" unless rjs
        tempfile<<"//= require handsontable/dist/handsontable.formula\n" unless hf
        tempfile<<"//= require best_in_place\n" unless b
        tempfile<<"//= require vd42-reveal/jquery.reveal\n" unless r
      end
      tempfile<<line
    end
    f.close
    tempfile.close

    # replace application.js with the tempfile
    FileUtils.mv(tempfile.path, path) if [!h,!n,!l].any?

    puts " => Adding stylesheets to application.css"

    # prepare for adding handsontable stylesheets to the application.css
    tempfile=Tempfile.new("stylesheets")
    path = Rails.root.to_s + "/app/assets/stylesheets/application.css.scss"
    f=File.new(path)

    # assume it is not required yet
    h=r=false

    # insert stylesheet requirement once, before the last line
    f.each do |line|
      h = true if line=~/handsontable\.full/
      f = true if line=~/handsontable\.formula/
      r = true if line=~/reveal/
      tempfile<<" *= require handsontable/dist/handsontable.full\n" if line=~/^ \*\// && !h
      tempfile<<" *= require handsontable/dist/handsontable.formula\n" if line=~/^ \*\// && !f
      tempfile<<" *= require vd42-reveal/reveal\n" if line=~/^ \*\// && !r
      tempfile<<line
    end
    f.close
    tempfile.close

    # replace the application.css with the tempfile
    FileUtils.mv(tempfile.path, path) unless h

    puts "\ndone."
  end
end
