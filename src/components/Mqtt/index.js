import React, { createContext, useEffect, useReducer, useState } from 'react';
import Connection from './Connection/Connection';
import Publisher from './Publisher/Publisher';
import Subscriber from './Subscriber/Subscriber';
import Receiver from './Receiver/Receiver';
import mqtt from 'mqtt';

export const NewContext = createContext([])
const initialState = {
	setupClicked: false,
}

function changeState(state, action) {
	switch(action.type){
		case 'setup':
			return {
				setupClicked: true
			};
		default:
			return initialState
	}
}


const HookMqtt = () => {
	const [client, setClient] 				= useState(null);
	const [isSubed, setIsSub] 				= useState(false);
	const [payload, setPayload] 			= useState({});
	const [connectStatus, setConnectStatus] = useState('Connect');
	const [state, dispatch] 				= useReducer(changeState, initialState);

	const mqttConnect = (host, mqttOption) => {
		setConnectStatus('Connecting');
		setClient(mqtt.connect(host, mqttOption));
	};

	useEffect(() => {
		if (client) {
			client.on('connect', () => {
				setConnectStatus('Connected');
			});
			client.on('error', (err) => {
				console.error('Connection error: ', err);
				client.end();
			});
			client.on('reconnect', () => {
				setConnectStatus('Reconnecting');
			});
			client.on('message', (topic, message) => {
				const payload = { topic, message: message.toString() };
				setPayload(payload);
			});
		}
	}, [client]);

	const mqttDisconnect = () => {
		if (client) {
			client.end(() => {
				setConnectStatus('Connect');
			});
		}
	}

	const mqttPublish = (context) => {
		if (client) {
			const { topic, qos, payload } = context;
			client.publish(topic, payload, { qos }, error => {
				if (error) {
					console.log('Publish error: ', error);
				}
			});
		}
	}

	const mqttSub = (subscription) => {
		if (client) {
			const { topic, qos } = subscription;
			client.subscribe(topic, { qos }, (error) => {
				if (error) {
					console.log('Subscribe to topics error', error)
					return
				}
				setIsSub(true)
			});
		}
	};

	const mqttUnSub = (subscription) => {
		if (client) {
			const { topic } = subscription;
			client.unsubscribe(topic, error => {
				if (error) {
					console.log('Unsubscribe error', error)
					return
				}
				setIsSub(false);
			});
		}
	};

	return (
		<>
			<NewContext.Provider value={{state, dispatch}}>
				<Connection connect={mqttConnect} disconnect={mqttDisconnect} connectBtn={connectStatus} />
				<Subscriber sub={mqttSub} unSub={mqttUnSub} showUnsub={isSubed} />
				<Publisher publish={mqttPublish} />
				<Receiver payload={payload} publish={mqttPublish} />
			</NewContext.Provider>
		</>
	);
}

export default HookMqtt;