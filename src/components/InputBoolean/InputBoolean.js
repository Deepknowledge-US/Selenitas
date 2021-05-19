// This function creates a new checkbox input in a window
// panelDiv is the element the new slider must be added to
// paramName is the name of the parameter (label of the boolean)
// current It is used to give to the checkbox a initial value
const InputBoolean = (panelDiv, windowTitle, p_id, current, sendUpdate, pub) => {
    let div = document.createElement('div');
    let lbl = document.createElement('label');
    let inp = document.createElement('input');

    lbl.textContent = p_id;

    inp.type        = 'checkbox';
    inp.id          = p_id + 'Input';
    inp.className   = 'boolean_input';
    inp.value       = current;
    
    if (inp.value === 'true') { inp.checked = true; }

    div.className = 'slidecontainer';
    div.appendChild(lbl);
    div.appendChild(inp);

    inp.oninput = function() {
        this.value = (this.value === 'true') ? 'false' : 'true'
        sendUpdate(windowTitle, p_id, inp.value, pub)
    }
    panelDiv.appendChild(div);
};

export default InputBoolean

