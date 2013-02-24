#!/usr/bin/env ruby

require 'rubygems'
require 'pit'
require 'gmail'

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
    puts email.message.html_part.decode_body
  end

  # Output as feed
end

g2f = Gunosy2Feed.new
email = g2f.getLatestMailFromGunosy
if email
  g2f.parse(email)
end
