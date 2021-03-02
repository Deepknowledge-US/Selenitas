var myObj;

// Called after form input is processed
function startConnect() {
    // Generate a random client ID
    clientID = "clientID-" + parseInt(Math.random() * 100);

    // Fetch the hostname/IP address and port number from the form
    host = document.getElementById("host").value;
    port = document.getElementById("port").value;

    // Print output for the user in the messages div
    document.getElementById("messages").innerHTML += '<span>Connecting to: ' + host + ' on port: ' + port + '</span><br/>';
    document.getElementById("messages").innerHTML += '<span>Using the following client value: ' + clientID + '</span><br/>';

    // Initialize new Paho client connection
    client = new Paho.MQTT.Client(host, Number(port), clientID);

    // Set callback handlers
    client.onConnectionLost = onConnectionLost;
    client.onMessageArrived = onMessageArrived;

    // Connect the client, if successful, call onConnect function
    client.connect({ 
        onSuccess: onConnect,
    });
}

// Called when the client connects
function onConnect() {
    // Fetch the MQTT topic from the form
    topic = document.getElementById("topic").value;

    // Print output for the user in the messages div
    document.getElementById("messages").innerHTML += '<span> Subscribing model: ' + topic +'</span><br/>';

    // Subscribe to the requested topic
    client.subscribe('from_server/#');
}

// Called when the client loses its connection
function onConnectionLost(responseObject) {
    console.log("onConnectionLost: Connection Lost");
    if (responseObject.errorCode !== 0) {
        console.log("onConnectionLost: " + responseObject.errorMessage);
    }
}

// Called when a message arrives
function onMessageArrived(message) {

    // console.log(message.payloadString)
    var myObj = JSON.parse( message.payloadString )
    //  Depending on the message a second parse will be neccessary
    if (typeof(myObj) == "string") {myObj = JSON.parse( myObj )}

    var topic = message.destinationName
    
    if (topic.indexOf('panel_info') != -1 ) {
        // Each element in myObj is a window
        for (const elem in myObj) {
            let window = myObj[elem]
            createWindow(window);
        }
        return;
    }

    for (const key in myObj) {
        if (Array.isArray(GB[key])) {
            GB[key].push(myObj[key])    // Push new value into the list
        } else {
            GB[key] = [ myObj[key] ]    // Create a list for the new key 
        }
    }

    var param = document.getElementById("param").value
    // document.getElementById("messages").innerHTML += '<span>Messagge received from Topic: ' + topic + '  |-> Received value: ' + GB[param][GB[param].length-1] + ', length '+ GB[param].length +'</span><br/>';
    // document.getElementById("messages").innerHTML += '<span>Messagge received from Topic: ' + topic + '  |-> Received value: ' + message.payloadString +'</span><br/>';
    // updateScroll(); // Scroll to bottom of window
    regenerateData('app_rescued')
}

// Called when the disconnection button is pressed
function startDisconnect() {
    client.disconnect();
    document.getElementById("messages").innerHTML += '<span>Disconnected</span><br/>';
    updateScroll(); // Scroll to bottom of window
}

// Updates #messages div to auto-scroll
function updateScroll() {
    var element = document.getElementById("messages");
    element.scrollTop = element.scrollHeight;
}

// This function is called when step button is pushed.
function sendStep() {
    console.log('ENVIANDO sendStep')
    // Publish a Message
    var message = new Paho.MQTT.Message('Step');
    message.destinationName = 'from_client/evacuation';
    message.qos = 0;
    client.send(message);
}

// This function is called when step button is pushed.
function sendRun() {
    console.log('ENVIANDO sendRun')
    // Publish a Message
    var message = new Paho.MQTT.Message('Run');
    message.destinationName = 'from_client/evacuation';
    message.qos = 0;
    client.send(message);
}

// This function is called when step button is pushed.
function sendSetup() {
    console.log('ENVIANDO sendSetup')
    // Publish a Message
    var message = new Paho.MQTT.Message('Setup');
    message.destinationName = 'from_client/evacuation';
    message.qos = 0;
    client.send(message);
}

// This function is called when reload button is pushed.
function sendReload() {
    console.log('ENVIANDO sendReload')
    // Publish a Message
    GB = new Map()
    var message = new Paho.MQTT.Message('Reload');
    message.destinationName = 'from_client/evacuation';
    message.qos = 0;
    client.send(message);
}

// This function is called when load button is pushed.
function sendLoad(obj,url) {
    topic = document.getElementById("topic").value;
    console.log('ENVIANDO sendRun');
    console.log(url);
    var file = obj.files[0].name;

    var path_tail = 'Resources/models/' + topic + '/' + file

    console.log(path_tail);

    // Publish a Message
    var message = new Paho.MQTT.Message('Load');
    message.destinationName = 'from_client/evacuation';
    message.qos = 0;
    client.send(message);
}


