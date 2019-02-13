#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'


url = 'http://static.bielsko.info/skrypty/jakoscpowietrza/cache/all.json?_=1550051092900'
web_url = 'http://www.bielsko.info/monitoring-jakosci-powietrza-on-line-bielsko-biala'

charset = nil
json = open(url) do |f|
  charset = f.charset
  f.read
end

@result = JSON.parse(json)
@pm25 = @result['PM25']
@pm10 = @result['PM10']


content = <<HEREDOC
#{@result['IJPString']} #{@result['temperatura']}°C | color=#{@result['Color']}
---
smog bb www | href=#{web_url}
Pył PM10: #{@pm10 || 0 } µg/m3 Norma: 50
Pył PM2,5: #{@pm25 || 0} µg/m3 Norma: 25
wilgotność: #{@result['wilgotnosc']} %
ciśnienie: #{@result['cisnienie']} hPa

HEREDOC

puts content
