require 'bunny'

abort "Usage: #{$PROGRAM_NAME} [binding_key]" if ARGV.empty?

# open a connection
connection = Bunny.new(host: '192.168.99.100')
connection.start

# open a channel
channel = connection.create_channel
channel.prefetch(10)

# create exchange
exchange = channel.topic('rlto_topic_exchange')

dlx  = channel.fanout("bunny.examples.dlx.exchange")
dlq  = channel.queue("", :exclusive => true).bind(dlx)

# create queue
queue_name = ARGV[0]
q = channel.queue("rlto_queue_#{queue_name}", durable: true, arguments: {"x-dead-letter-exchange" => dlx.name})
q.bind(exchange, routing_key: queue_name)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  q.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
    if false
      channel.acknowledge(delivery_info.delivery_tag, false)
      puts " [x] Received #{delivery_info.routing_key}:#{body}"
    else
      channel.reject(delivery_info.delivery_tag, false)
      puts " [x] Rejected #{delivery_info.routing_key}:#{body}"
      puts dlq.message_count
    end
  end
rescue Interrupt => _
  channel.close
  connection.close
end
