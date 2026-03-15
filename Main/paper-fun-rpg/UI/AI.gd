extends Node

const API_URL = "https://devsocket.025555.xyz/"
const AUTH_TOKEN = "b8d4de9d-4c35-4143-b0c4-61c3776c0586"

# Send a message and get response text asynchronously
# Returns String on success, null on failure
func send_message(message: String) -> String:
	if message.strip_edges() == "":
		return ""

	# Create HTTPRequest dynamically
	var http = HTTPRequest.new()
	get_tree().root.add_child(http)

	var headers = ["Content-Type: application/json", "Authorization: Bearer " + AUTH_TOKEN]
	var body = JSON.stringify({"message": message})

	var err = http.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()
		return ""

	# Await the request_completed signal
	# request_completed returns a tuple: (result, response_code, headers, body)
	var result_tuple = await http.request_completed
	var result = result_tuple[0]
	var response_code = result_tuple[1]
	var body_bytes = result_tuple[3]

	var response_text: String = ""

	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var json = JSON.new()
		if json.parse(body_bytes.get_string_from_utf8()) == OK:
			var data = json.get_data()
			if data.has("message"):
				response_text = str(data["message"])

	http.queue_free()
	return response_text
