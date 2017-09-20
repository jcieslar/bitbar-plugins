#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'open-uri'
require 'json'
require 'date'

url = 'https://panel.walutomat.pl/api/v1/best_offers.php?curr1=EUR&curr2=PLN'
web_url = 'https://panel.walutomat.pl/logowanie'.freeze
file_path = "#{Dir.home}/.bitbar-walutomat-plugin-store.txt".freeze

charset = nil
json = open(url) do |f|
  charset = f.charset
  f.read
end

@result = JSON.parse(json)

def color
  if @result["buy"] >= @result["buy_old"]
    "green"
  else
    "red"
  end
end

def load_min_max(path)
  unless File.exist?(path)
    save_min_max(path,0,10,Date.today.day)
  end
  line = File.open(path).read
  @max, @min, @day = line.split(':').map { |l| Float(l).round(4) }
  @max, @min = [0,10] if @day != Date.today.day
end

def save_min_max(path, max, min, day)
  File.open(path, 'w') { |file| file.write("#{max}:#{min}:#{day}") }
end

load_min_max(file_path)
buy_value = @result['buy'].to_f.round(4)

if buy_value
  @max = buy_value if buy_value > @max
  @min = buy_value if buy_value < @min
  save_min_max(file_path, @max, @min, Date.today.day)
end

content = <<HEREDOC
€#{@result['buy']} | color=#{color()}
---
walutomat | href=#{web_url}
max: €#{@max || 0 }
min: €#{@min || 0}

HEREDOC

puts content
