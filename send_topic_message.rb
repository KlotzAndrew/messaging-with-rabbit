require 'bunny'

abort "Usage: #{$0} [routing_key, message]" if ARGV.empty?

# open a connection
conn = Bunny.new(host: "192.168.99.100")
conn.start

# open a channel
ch = conn.create_channel

# create exchange
x = ch.topic("rlto_topic_exchange")

# publish message
routing_key = ARGV.shift
msg         = ARGV.empty? ? "Hello RLTO!" : ARGV.join(" ")
x.publish(msg, :routing_key => routing_key)

puts " [x] Sent #{routing_key}:#{msg}"

ch.close
conn.close
