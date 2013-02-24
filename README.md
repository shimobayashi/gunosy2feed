# Gunosy2Feed
Convert mail from gunosy to rss feed.

1. Get latest mail labeled 'Gunosy' from gmail via IMAP
2. Parse mail body
3. Output as feed

You can add this to cron job and redirect to hosted directory like this:
```
0 8 * * * bash -lc "~/gunosy2feed/gunosy2feed.rb > /var/www/gunosy2feed.xml"
```
