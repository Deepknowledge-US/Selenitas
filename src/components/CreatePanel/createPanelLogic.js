
const sendUpdate = (windowTitle, param, value, pub) => {
    pub({
        topic: 'from_client',
        qos: 0,
        payload: 'Update/' + windowTitle + '/' + param + '/' + value
    })
}

// const anyOtherFunction = ...

export {
    sendUpdate,
    // anyOtherFunction
}