require 'ostruct'

#require 'PortPublisher'
require 'OverridePeerrb'
require 'debug_me'



##################################################
## Globals required by SamsonHeader#new

$run_record             = OpenStruct.new
$run_record.id          = 0 ## needs to be set at run-time

$OPTIONS                = Hash.new
$OPTIONS[:unit_number]  = 0

peer_key		= 'EngagementManagerStandinWebApp'
node			= Node.find_by_ip_address(ENV['IPADDRESS'])

control_port	= 3000 ## FIXME: self.request.port <-- not working properly
conditions		= "node_id = #{node.id} AND control_port = #{control_port}"

$run_peer_record = RunPeer.find_by_peer_key(peer_key, :conditions => conditions)
$run_peer_record = RunPeer.new if $run_peer_record.nil?

$run_peer_record.node_id      = node.id
$run_peer_record.pid          = Process.pid
$run_peer_record.control_port = control_port
$run_peer_record.status       = 2
$run_peer_record.peer_key     = peer_key
$run_peer_record.save


#############################################################
## Establish connection with the IseDispatcher on the IseQueen
## Use remote apps channel 8003

#$dispatcher_connection = PortPublisher.new(ENV['ISE_QUEEN'], 8003)
