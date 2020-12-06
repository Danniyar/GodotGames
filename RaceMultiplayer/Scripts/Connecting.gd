extends ColorRect

const CONNECT_TEXT = ["Waiting for players...", "Connecting to server..."]

func set_connect_type(host):
	show()
	if host:
		$Label.text = CONNECT_TEXT[0] + "\n"
		for a in IP.get_local_addresses():
			$Label.text += a + "\n"
	else:
		$Label.text = CONNECT_TEXT[1]
