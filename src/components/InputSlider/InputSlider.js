
// This function creates a new slider in a window
// panelDiv is the element the new slider must be added to
// window is the name of the window the parameter belongs to
// paramName is the name of the parameter (label of the slider)
// min slider value
// max slider value
// step determines the slider step
// current It is used to give to the slider a initial value


const InputSlider = (panelDiv, windowTitle, paramName,min,max,step,current, sendUpdate, pub) => {
    let div = document.createElement('div');
    let lbl = document.createElement('label');
    let inp = document.createElement('input');
    let rng = document.createElement('input');

    lbl.textContent = paramName;

    inp.type      = 'text';
    inp.id        = paramName+'Input';
    inp.className = 'slider_input';

    rng.type  = 'range';
    rng.id    = paramName+'Range';
    rng.className = 'slider_range'
    rng.min   = min;
    rng.max   = max;
    rng.step  = step;

    rng.value = current;
    inp.value = current;

    div.className = 'slidecontainer';
    div.appendChild(lbl);
    div.appendChild(inp);
    div.appendChild(rng);

    // When the slider is moved, input value is updated
    rng.oninput = function() {
        inp.value = this.value;
        sendUpdate(windowTitle, paramName, rng.value, pub)
    }
    // The slider is updated when a new input is set
    inp.oninput = function() {
        rng.value = this.value;
        sendUpdate(windowTitle, paramName, inp.value, pub)
    }
    panelDiv.appendChild(div);
};


export default InputSlider
