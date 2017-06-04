require 'bunny'

abort "Usage: #{$PROGRAM_NAME} [routing_key, message]" if ARGV.empty?

# open a connectionection
connection = Bunny.new(host: '192.168.99.100')
connection.start

# open a channel
channel = connection.create_channel
channel.confirm_select

# create exchange
exchange = channel.topic('rlto_topic_exchange')

# get message arguments
routing_key = ARGV.shift
msg         = ARGV.empty? ? 'Hello RLTO!' : ARGV.join(' ')

# publish message
exchange.publish(msg, routing_key: routing_key)
if exchange.wait_for_confirms
  puts " [x] Sent #{routing_key}:#{msg}"
else
  puts " [x] Failed #{routing_key}:#{msg}"
end

# cleanup
channel.close
connection.close
