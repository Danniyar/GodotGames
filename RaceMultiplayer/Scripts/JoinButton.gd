extends Button

signal set_connect_type

func _pressed():
	if $IP.text.is_valid_ip_address() && Net.playername != "":
		join()
	else:
		$InvalidIP.show()

func join():
	get_parent().get_node("MAXPLAYERS").visible = false
	get_parent().get_node("Offline").visible = false
	get_parent().get_node("Name").visible = false
	get_parent().get_node("ColorPicker").visible = false
	get_parent().get_node("SettingsButton").visible = false
	Net.initialize_client($IP.text)
	emit_signal("set_connect_type", false)
