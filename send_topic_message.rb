require 'bunny'

abort "Usage: #{$PROGRAM_NAME} [routing_key, message]" if ARGV.empty?

# open a connection
conn = Bunny.new(host: '192.168.99.100')
conn.start

# open a channel
ch = conn.create_channel
ch.confirm_select

# create exchange
x = ch.topic('rlto_topic_exchange')

# get message arguments
routing_key = ARGV.shift
msg         = ARGV.empty? ? 'Hello RLTO!' : ARGV.join(' ')

# publish message
x.publish(msg, routing_key: routing_key)
if x.wait_for_confirms
  puts " [x] Sent #{routing_key}:#{msg}"
else
  puts " [x] Failed #{routing_key}:#{msg}"
end

# cleanup
ch.close
conn.close
