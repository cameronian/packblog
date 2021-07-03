# frozen_string_literal: true

require 'redcarpet'

RSpec.describe Packblog do
  it "has a version number" do
    expect(Packblog::VERSION).not_to be nil
  end

  it 'load invalid markdown template shall raise error' do
    expect { PackblogEngine.load_markdown(nil) }.to raise_exception(Packblog::Error,"Load markdown file with empty path")
  end


  it 'load markdown template and convert into packaged format' do
    eng = PackblogEngine.load_markdown('crystal.md')
    eng.tag_css_class = "tag"
    expect(eng).not_to be_nil
    expect(eng.is_a?(PackblogEngine)).to be true

    eng.title = "Wow"

    jsonStr = eng.generate
    expect(jsonStr).not_to be_nil

    js = JSON.parse(jsonStr)
    expect(js).not_to be_nil
    expect(js.keys.include?("post")).to be true

    pbe, dat = PackblogEngine.parse_blog_record(jsonStr)
    expect(dat[:pid] == js["pid"]).to be true
    p pbe
    p dat
    #r = Redcarpet::Render::HTML.new(prettify: true)
    #mdp = Redcarpet::Markdown.new(r)
    #mdp.render(js["post"])
  end

end
