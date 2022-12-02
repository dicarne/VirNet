extends Panel

var server = ""
var netname = ""
var netpsd = ""
var ip = ""
var cur_save_path = "user://config.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_window_event_callback(quit_win)
	#get_tree().auto_accept_quit = false
	stop()
	FileAccess.open("./n2n/logs.log", FileAccess.WRITE_READ)
	if FileAccess.file_exists(cur_save_path):
		var f = FileAccess.open(cur_save_path, FileAccess.READ_WRITE)
		if f == null:
			printerr("open file error: " + str(FileAccess.get_open_error()))
			return
		var txt = f.get_as_text()
		var j = JSON.parse_string(txt)
		server = j.get("host", "")
		netname = j.get("name", "")
		netpsd = j.get("pass", "")
		ip = j.get("ip", "")
		%server_line.text = server
		%name_line.text = netname
		%psd_line.text = netpsd
		%ip_line.text = ip

func _on_server_line_text_changed(new_text):
	server = new_text


func _on_name_line_text_changed(new_text):
	netname = new_text


func _on_psd_line_text_changed(new_text):
	netpsd = new_text

var thread: Thread = null
func _on_connect_button_pressed():
	stop()
	%log.text = ""
	if server == "" or netname == "" or netpsd == "":
		%log.text = "服务器、网络名、密码不能为空！"
		return
	var savedata = JSON.stringify({
		"host": server,
		"name": netname,
		"pass": netpsd,
		"ip": ip,
	})
	var f = FileAccess.open(cur_save_path, FileAccess.WRITE_READ)
	if f == null:
		printerr("open file error: " + str(FileAccess.get_open_error()))
		return
	f.store_string(savedata)
	if FileAccess.file_exists("n2n/edge.exe"):
		if thread == null:
			last_log = ""
			thread = Thread.new()
			thread.start(run)
		else:
			%log.text = "已经在运行"

func run():
	var code = OS.execute("powershell.exe", ["-Command", "./n2n/edge.exe -c " + netname +" -k " + netpsd + " -a " + ip + " -l " + server + " -p 50001 > ./n2n/logs.log"])
	thread = null

func stop():
	var op = []
	OS.execute("CMD.exe", ["/C", "for /f \"tokens=2 \" %a in ('tasklist  /fi \"imagename eq edge.exe\" /nh') do taskkill /f /pid %a"], op)


func _on_ip_line_text_changed(new_text):
	ip = new_text

func quit_win(e):
	if e == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
		stop()
		get_tree().quit()

var last_log = ""
func _on_logs_timer_timeout():
	var f = FileAccess.open("./n2n/logs.log", FileAccess.READ)
	if f == null:
		printerr("open logs error: " + str(FileAccess.get_open_error()))
		return
	var leng = f.get_length()
	var txt = f.get_buffer(leng).get_string_from_utf16()
	if txt != last_log:
		last_log = txt
		if txt.contains("[OK] edge <<<"):
			%log.text = "成功！"
			%install.visible = false
		elif txt.contains("ERROR: authentication error, MAC or IP address already in use or not released yet by supernode"):
			%log.text = "ip已占用，检查是否重复！正在重新连接中……"
			%install.visible = false
		elif txt.contains("No Windows tap devices found, did you run tapinstall.exe?"):
			%log.text = "是否已安装Tap网络驱动？"
			%install.visible = true
		else:
			%log.text = txt
			%install.visible = false



func _on_install_button_pressed():
	var code = OS.execute("powershell.exe", ["-Command", "./n2n/tap-windows-9.24.2-I601-Win10.exe"])
