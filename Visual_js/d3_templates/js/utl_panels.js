function sendUpdate(window, param, value ){
    // Publish a Message thet contains: update instruction + window title + param + new value
    var message = new Paho.MQTT.Message('Update/' + window + '/' + param + '/' + value);
    message.destinationName = 'from_client/evacuation/';
    message.qos = 0;
    client.send(message);
}


// This function creates a new slider in a window
// panelDiv is the element the new slider must be added to
// window is the name of the window the parameter belongs to
// p_id is the name of the parameter (label of the slider)
// min slider value
// max slider value
// step determines the slider step
// current It is used to give to the slider a initial value
function createSlider(panelDiv, window, p_id,min,max,step,current){
    let div = document.createElement('div');
    let lbl = document.createElement('label');
    let inp = document.createElement('input');
    let rng = document.createElement('input');

    lbl.textContent = p_id;

    inp.type      = 'text';
    inp.id        = p_id+'Input';
    inp.className = 'slider_input';

    rng.type  = 'range';
    rng.id    = p_id+'Range';
    rng.min   = min;
    rng.max   = max;
    rng.step  = step;

    rng.value = current;
    inp.value = current;

    div.className = 'slidecontainer';
    div.appendChild(lbl);
    div.appendChild(inp);
    div.appendChild(rng);

    // When the slider is moved, input value is updated and an mqtt message is sent
    rng.oninput = function() {
        inp.value = this.value;
        sendUpdate(window, p_id, rng.value)
    }
    // The slider is updated when a new input is set
    inp.oninput = function() {
        rng.value = this.value;
        sendUpdate(window, p_id, inp.value)
    }
    panelDiv.appendChild(div);
};



// This function creates a new checkbox input in a window
// panelDiv is the element the new slider must be added to
// window is the name of the window the parameter belongs to
// p_id is the name of the parameter (label of the boolean)
// current It is used to give to the checkbox a initial value
function createBoolean(panelDiv, window, p_id, current){
    let div = document.createElement('div');
    let lbl = document.createElement('label');
    let inp = document.createElement('input');

    lbl.textContent = p_id;

    inp.type        = 'checkbox';
    inp.id          = p_id + 'Input';
    inp.className   = 'boolean_input';
    inp.value       = current;
    
    if (inp.value == 'true') { inp.checked = true; }

    div.className = 'slidecontainer';
    div.appendChild(lbl);
    div.appendChild(inp);

    inp.oninput = function() {
        this.value = (this.value == 'true') ? 'false' : 'true'
        sendUpdate(window, p_id, inp.value)
    }
    panelDiv.appendChild(div);
};


function createWindow(window){
    var windowTitle = window.title;
    var widthParam = window.with;
    var heightParam = window.height;
    var xCoor = window.x;
    var yCoor = window.y;
    var inputs = window.ui_settings;
    var order = window.order;

    console.log('createWindow 1')
    console.log(window)

    let panelDiv = document.createElement('div');
    panelDiv.className = 'panel_div';

    order.forEach(name => {
        let key = name
        let val = inputs[name]

        if (val.type == 'slider'){
            createSlider(panelDiv, windowTitle, key, val.min, val.max, val.step, window[key])
        }else if(val.type == 'boolean'){
            createBoolean(panelDiv, windowTitle, key, window[key])
        }
    });

    jsPanel.create({
        theme: 'dark',
        headerLogo: '<i class="fad fa-home-heart ml-2"></i>',
        headerTitle: windowTitle,
        panelSize: {
            width: () => { return Math.min(widthParam, window.innerWidth*0.9);},
            height: () => { return Math.min(heightParam, window.innerHeight*0.6);}
        },
        position: 'left-top ' + xCoor + ' ' + yCoor,
        animateIn: 'jsPanelFadeIn',
        onwindowresize: true,
        content: panelDiv,
            
        onbeforeclose: function() {
            return confirm('Do you really want to close the ' + windowTitle + ' panel?');
        }
    });

}