import React, { useEffect, useState, useContext } from 'react';
import { Card, List } from 'antd';
import createWindow from '../../CreatePanel/CreatePanel'
import Chart from '../../D3/Chart/Chart'
import { NewContext } from '../index'

import './receiver.css'

const Receiver = ({ payload, publish }) => {
	const {state, dispatch} 	  = useContext(NewContext);
	const [init, setInit]         = useState(false);
	const [messages, setMessages] = useState([]);

	// "monitors" is a Map of Array of Maps. Each one of this Arrays contains the information to build a graphical monitor.
	// This maps have two keys -> "id" is the name of the var we want to track and "values" are a list of maps, each one of them containing two keys -> time (x axis) and a value (y axis) associated to this time. 
	// When component is created, "monitors" is an empty Array, but it will be populated with the mqtt messagges.

	// const monitors = { 
	// 		'var_1':  [ {time: 0, value: 11}, {time: 1, value: 20}, ... ] ,
	// 		'var_2':  [ {time: 0, value: 11}, {time: 1, value: 20}, ... ]
	// };
	const [monitors, setmonitors] = useState({});

	useEffect( () => {
		if (state.setupClicked) {
			setmonitors({});
			dispatch({type: 'unSetup'});
		}
	}, [state]);

	// At the moment, two posible topics:
	// - from_server/panel_info
	// - from_server/update
	const topicOption = {

		'from_server/panel_info': (jsonObj) => {
			for (const [k,v] of Object.entries(jsonObj) ) {
				if (k !== 'Monitor') {
					createWindow(v, publish)
				}
			}
		},

		'from_server/update': (jsonObj) => {
			if (Object.keys(monitors).length === 0) {
				setInit(true)

				for (const [k,v] of Object.entries(jsonObj) ) {
					monitors[k] = [{time: 0, value:v}];
				}

			}else{
				for (const [k,v] of Object.entries(jsonObj) ) {

					const targetVar 	= monitors[k];

					const lastElement  	= targetVar[targetVar.length -1];
					const newTime  		= lastElement.time + 1;
					const newInput		= {time: newTime, value:v};
					targetVar.push(newInput)	
				}
				// console.log(monitors['app_rescued'].length)
			}			
		},

	}

	useEffect(() => {
		if (payload.topic) {
			const jsonObject = JSON.parse(payload.message);
			setMessages(messages => [...messages, payload]);

			topicOption[payload.topic](jsonObject);
		}
	}, [payload]);

	const renderListItem = (item) => (
		<List.Item>
			<List.Item.Meta
				title={item.topic}
				description={item.message}
			/>
		</List.Item>
	);

	return (
		<Card title="Receiver">
			{/* When Uncommented, incoming MQTT messages are displayed */}
			{/* <List
				size="small"
				bordered
				dataSource={messages}
				// renderItem={renderListItem}
				style={{maxHeight:'15em' ,overflow:'scroll'}}
			/> */}
			{ init && 
				<div id='allMonitorsDiv'>
					{Object.keys(monitors).map(function(key) {
						const newMonitor = [{id:key, values:monitors[key]}]
						return <div key={key} className='monitorDiv'> <Chart data={newMonitor} /> </div>;
				  	})}
				</div>
			}
			
		</Card>
	);
}

export default Receiver;
