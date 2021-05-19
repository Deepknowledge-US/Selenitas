const removeElementsByClass = (className) => {
    const elements = document.getElementsByClassName(className);
    while(elements.length > 0){
        elements[0].parentNode.removeChild(elements[0]);
    }
}

export const modelLoad = (value, publish) => {
    // New panels are created with class 'panel_div', we need to remove this elements before create new ones
    removeElementsByClass('jsPanel')

    // In the Lua side, models must be created in a folder named as the model file and this folder must be placed inside the Resources folder
    const fileName 	= value.target.files[0].name
    const dirName 	= fileName.split('.')[0]

    // At the moment, the separator is "|"
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'Load|' + dirName + '/' + fileName
    })
};

export const modelSetup = (publish, dispatch) => {
    dispatch({type: 'setup'});
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'Setup'
    });
};

export const modelStep = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'Step'
    })
};

export const modelRun = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'Run'
    })
};

export const modelSpeed = (value,publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'Speed:'+ value
    })
};

export const modelViewStats = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'ToggleView:Stats'
    })
};

export const modelViewWindows = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'ToggleView:Windows'
    })
};

export const modelViewFamilies = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'ToggleView:Families'
    })
};

export const modelViewGrid = (publish) => {
    publish({
        topic: 'from_client',
        qos: 0,
        payload: 'ToggleView:Grid'
    })
};
