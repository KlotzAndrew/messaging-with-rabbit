require 'bunny'

abort "Usage: #{$PROGRAM_NAME} [binding_key]" if ARGV.empty?

# open a connection
connection = Bunny.new(host: '192.168.99.100')
connection.start

# open a channel
channel = connection.create_channel

# create exchange
exchange = channel.topic('rlto_topic_exchange')

# create queue
queue_name = ARGV[0]
queue = channel.queue("rlto_queue_#{queue_name}", durable: true)
queue.bind(exchange, routing_key: queue_name)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  # consume messages
  queue.subscribe(block: true) do |delivery_info, properties, body|
    puts " [x] Received #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  # cleanup
  channel.close
  connection.close
end
