#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'


url = 'https://www.tms.pl/quotes.php?instruments%5B%5D=EURPLN.pro'
web_url = 'https://www.tms.pl/rynek/kursy-walut'

charset = nil
json = open(url) do |f|
  charset = f.charset
  f.read
end

@result = JSON.parse(json)['EURPLN.pro']

def color
  if @result["updown"] >= "up"
    "green"
  else
    "red"
  end
end

content = <<HEREDOC
f:#{@result['bid']} | color=#{color()}
---
tms kurs | href=#{web_url}
date: #{@result['data']} %
time: #{@result['time']}

HEREDOC

puts content
