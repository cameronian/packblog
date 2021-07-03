#!/usr/bin/env ruby

require 'tty/prompt'

require_relative '../lib/packblog'

pmt = TTY::Prompt.new

pmt.ok "Packblog client V#{Packblog::VERSION}"

begin
  

  md = pmt.ask "Please provide the Markdown file:", required: true do |q|
    q.validate -> (path) { 
      ppath = File.expand_path(path)
      File.exist?(ppath) 
    }
    q.messages[:valid?] = "Given file '%{value}' does not exist"
  end

  pbe = PackblogEngine.load_markdown(md)
  
  pbe.title = pmt.ask("Title of the post :", required: true)
  p pbe

  pbe.tag_css_class = pmt.ask "CSS class name for tag (optinal) : "

  pmt.ask "Publish at (dd/MMM/yyyy HH:mm) (Default: Immediately) : "

  out = pmt.ask "Output file : " do |q|
    q.default "#{File.basename(md)}.brec"
  end

  out ||= "#{File.basename(md)}.brec"

  File.open(out,"wb") do |f|
    f.write pbe.generate
  end

  pmt.ok "Blog record generated at '#{out}'"

rescue TTY::Reader::InputInterrupt
  pmt.ok "\nAborted"
rescue Exception => ex
  pmt.error "\nException: #{ex.message}"
end

