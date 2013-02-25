#!/usr/bin/env ruby

require 'rubygems'
require 'pit'
require 'gmail'
require 'nokogiri'
require 'rss/maker'

class Gunosy2Feed
  def initialize()
    @pit = Pit.get(
      'gmail.com',
      :require => {
        'host' => 'imap.gmail.com',
        'port' => 993,
        'use_ssl' => true,
        'login' => '',
        'password' => '',
      }
    )
  end

  # Get latest mail labeled 'Gunosy' from gmail via IMAP
  def getLatestMailFromGunosy()
    Gmail.connect(@pit['login'], @pit['password']) do |gmail|
      return gmail.mailbox('Gunosy').emails.last
    end
    return nil
  end

  # Parse mail body
  def parse(email)
    html = email.message.html_part.decode_body
    doc = Nokogiri::HTML(html)
    entries = []

    doc.xpath('//table[3]//tr/td/div').each do |div|
      a = div.xpath('./p[1]/a[1]').first
      title, url = a.text, a['href']

      img = div.xpath('./div[1]//img[1]').first
      thumb_url = img ? img['src'] : nil

      p = div.xpath('./p[2]').first
      desc = p.text.strip

      entries << {
        :title => title,
        :url => url,
        :thumb_url => thumb_url,
        :desc => desc,
      }
    end

    return entries
  end

  # Output as feed
  def compose(entries)
    rss = RSS::Maker.make('2.0') do |rss|
      rss.channel.title = "Gunosy2Feed"
      rss.channel.description = "Entries from Gunosy"
      rss.channel.link = 'https://github.com/shimobayashi/gunosy2feed'

      for entry in entries
        item = rss.items.new_item
        item.title = entry[:title]
        item.link = entry[:url]
        item.description = (entry[:thumb_url] ? %Q(<img src="#{entry[:thumb_url]}" />) : '') + %Q(<p>#{entry[:desc]}</p>)
        item.date = Time.now
      end
    end

    return rss
  end
end

g2f = Gunosy2Feed.new
email = g2f.getLatestMailFromGunosy
if email
  entries = g2f.parse(email)
  puts g2f.compose(entries)
end
