#!/usr/bin/env ruby

require 'rubygems'
require 'pit'
require 'net/imap'
require 'kconv'

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
    imap = Net::IMAP.new(@pit['host'], @pit['port'].to_i, @pit['use_ssl'])
    imap.login(@pit['login'], @pit['password'])

    imap.select('Inbox')
    exists = imap.responses['EXISTS'][-1].to_i
    return nil if exists < 1

    imap.fetch(1..exists, ['ENVELOPE', 'RFC822.TEXT']).each do |f|
      from = f.attr['ENVELOPE'].from.first
        if (from.mailbox == 'noreply' and from.host == 'gunosy.com')
          return f
        end
    end

    return nil
  end

  # Parse mail body
  def parse(message)
    body = message.attr['RFC822.TEXT'] ? message.attr['RFC822.TEXT'].toutf8 : ''
    puts body
  end

  # Output as feed
end

g2f = Gunosy2Feed.new
message = g2f.getLatestMailFromGunosy
if message
  g2f.parse(message)
end
