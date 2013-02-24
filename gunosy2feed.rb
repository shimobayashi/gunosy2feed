#!/usr/bin/env ruby

require 'rubygems'
require 'pit'
require 'gmail'
require 'nokogiri'

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

  # Get latest gunosy mail from gmail via IMAP
  def getLatestMailFromGunosy()
    Gmail.connect(@pit['login'], @pit['password']) do |gmail|
      return gmail.mailbox('Gunosy').emails.first
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

      puts title, url, thumb_url, desc
    end
  end

  # Output as feed
end

g2f = Gunosy2Feed.new
email = g2f.getLatestMailFromGunosy
if email
  g2f.parse(email)
end
