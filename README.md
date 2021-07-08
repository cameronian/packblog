# Packblog

Packblog is meant to provide client to publish blog post of Markdown to [SRBlog engine](https://github.com/cameronian/SRBlog).

Packblog support images and tagging to the Markdown post and this client shall package it in the single JSON file to be uploaded to the SRBlog engine

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'packblog'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install packblog

## Usage

Packblog is meant to be run in command line. 

> packblog

Write the normal Markdown content, with two custom fields:
* Whenever Packblog see '<%= tag 'xxx', 'yyy' %>', it will be ignored in Markdown file but it will be tagged inside the Packblog JSON format. SRBlog engine shall link the tag with blog post when it is being parsed later.
* Whenever Packblog see '<%= image 'xxxx.png' %>', it will find the xxxx.png at the same directory as the Markdown file and convert that into public images that is able to load at SRBlog engine.

Packblog is developed in Ruby so yeah, it is ERB template format.

The rest of the Markdown is standard and it is now using [Redcarpet](https://github.com/vmg/redcarpet) to parse the Markdown file.

Example output
```sh
> packblog

Packblog client V0.0.15
Please provide the Markdown file: mypost.md   <-- This must be in current directory
Title of the post : Main Title                <-- This shall be the main title
Sub title of the post : Sub Title             <-- This shall be the sub title
CSS class name for tag :                      <-- This is the CSS class name of the tag. Very likely shall be gone in next cycle
Output file :  mypost.md.brec                 <-- System shall prompt for output file 
Publish at (dd/MMM/yyyy HH:mm) :              <-- Ignore this first this is not parsed
Author :  Ian                                 <-- Author of the post
New blog record generated at mypost.md.brec
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

