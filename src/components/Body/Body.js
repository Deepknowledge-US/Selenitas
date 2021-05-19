import React    from 'react';


import './body.css'
import HookMqtt from '../Mqtt/index'

function BodyContent(props) {
    return (
        <div id="body-div" >
            <div className="container-fluid" style = {{ padding: 24, minHeight: '100vh' }}>
				<HookMqtt id='mqtt' />
			</div>
        </div>
    );
}

export default BodyContent;