extends Node

const RPC_PORT = 31400
var MAX_PLAYERS = 2
var current_players = 1
const TESTING_IP = "127.0.0.1"
const OFFLINE_TESTING = false
var playername = ""
var sensivity = 1
var map = 1

var blue = "2f90f9"
var green = "33f541"
var pink = "de33d7"
var red = "f5130a"
var black = "00001b"
var white = "fff9f9"
var yellow = "fff30e"
var purple = "6d03fa"

var cur_color = "2f90f9"

var net_id = null
var is_host = false
var peer_ids = []
var offline = false

func initialize_server():
	is_host = true
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(RPC_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	#print("initialized as host")

func initialize_client(server_ip):
	if OFFLINE_TESTING:
		server_ip = TESTING_IP
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, RPC_PORT)
	get_tree().network_peer = peer
	#print("initialized as client")

func set_ids():
	net_id = get_tree().get_network_unique_id()
	peer_ids = get_tree().get_network_connected_peers()
	#print("ID is " + str(net_id) + " and peer IDs are " + str(peer_ids))
