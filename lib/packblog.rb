# frozen_string_literal: true

require_relative "packblog/version"

require 'toolrack'
require 'erb'
require 'base64'
require 'json'
require 'securerandom'

module Packblog
  class Error < StandardError; end
  # Your code goes here...

  module ClassMethods
  end
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  attr_accessor :markdown
  # instance
  def render
    raise Error, "Template is not given" if is_empty?(@markdown)
    temp = ERB.new(File.read(@markdown))
    temp.result(binding)
  end

  def parse_tags(*args,&block)
    res = []
    args.each do |a|
      if block
        res << block.call(:convert_tagged_link, a)
      else
        res << find_tagged_path(a)
      end
    end
    res.join(" ")
  end

  def convert_image(path)
    if not_empty?(path)
      path = File.expand_path(path) 
      raise Error, "Given image '#{path}' not available" if not File.exist?(path) 
      img = nil
      File.open(path,'rb') do |f|
        img = f.read
      end
      { name: File.basename(path), image: Base64.strict_encode64(img) }
    end
  end

end

class PackblogEngine
  include Packblog
  include ToolRack::ConditionUtils
  extend ToolRack::ConditionUtils

  attr_accessor :tag_css_class, :title, :sub_title
  def self.load_markdown(path)
    raise Error, "Load markdown file with empty path" if is_empty?(path)
    raise Error, "Markdown file is not given" if is_empty?(path)
    raise Error, "Markdown file does not exist" if not File.exist?(path)
    eng = PackblogEngine.new
    eng.markdown = path
    eng
  end

  def initialize(template = { })
    @tags = []
    @tag_links = []
    @images = []
  end

  def self.parse_blog_record(brec)
    raise Error, "Blog record is not empty" if is_empty?(brec)

    rec = JSON.load(brec)
    pbe = PackblogEngine.new
    pbe.title = rec["title"]
    pbe.sub_title = rec["sub_title"]

    dat = { }
    dat[:publish_at] = rec["publish_at"]
    dat[:created_at] = rec["created_at"]
    dat[:updated_at] = rec["updated_at"]
    dat[:author] = rec[:author]
    dat[:snippet] = rec[:snippet]
    dat[:pid] = rec["pid"]

    [pbe,dat]
  end

  # methods inside template
  def tags(*args,&block)
  
    res = parse_tags(*args) do |ops,val|
      case ops
      when :convert_tagged_link
        to_tagged_path(val)
      when :tag_class
        @tag_class
      end
    end

    @tags += args
    res
  end

  def image(path)
    @images << convert_image(path)
    "![images](/uploads/#{@images.last[:name]})"
  end

  def generate(&block)  
    raise Error, "Title should not be empty" if is_empty?(@title)
    raise Error, "Markdown file is not given" if is_empty?(@markdown)
    raise Error, "Markdown file does not exist" if not File.exist?(@markdown)

    res = { }
    res[:title] = @title
    res[:sub_title] = @sub_title
    # render method from Packblog module shall render the @markdown
    res[:post] = render
    res[:images] = @images

    if block
      res[:publish_at] = block.call(:publish_at)
      res[:created_at] = block.call(:created_at)
      res[:pid] = block.call(:post_id)
      res[:author] = block.call(:author)
      #res[:snippet] = block.call(:snippet)
    else
      # reverse Time.at(i)
      res[:publish_at] = Time.now.to_i
      res[:created_at] = Time.now.to_i
      res[:pid] = SecureRandom.uuid
      res[:author] = "Whoever"
      #res[:snippet] = ""
    end
    
    res[:updated_at] = Time.now.to_i

    res.to_json
  end


  private
  def to_tagged_path(tag)
    tagId = tag.downcase
    tagId.gsub!(" ","_")
    if not_empty?(@tag_css_class)
      res = []
      res << "<span class=\"#{@tag_css_class}\">"
      res << "[\##{tag}](/posts/tag?id=#{tagId}/)"
      res << "</span>"
    else
      "[\##{tag}](/posts/tag?id=#{tagId}/)"
    end
  end


end


