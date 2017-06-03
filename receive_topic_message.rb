require 'bunny'

abort "Usage: #{$0} [binding_key]" if ARGV.empty?

# open a connection
conn = Bunny.new(host: "192.168.99.100")
conn.start

# open a channel
ch = conn.create_channel

# create exchange
x = ch.topic("rlto_topic_exchange")

# create queue
queue_name = ARGV[0]
q = ch.queue("rlto_queue_#{queue_name}", :durable => true)
q.bind(x, :routing_key => queue_name)

puts " [*] Waiting for logs. To exit press CTRL+C"

begin
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  ch.close
  conn.close
end
