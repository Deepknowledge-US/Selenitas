import React, { useContext } from 'react';
import { Card, Form, Input, Row, Col, Button, Select } from 'antd';

const Subscriber = ({ sub, unSub, showUnsub }) => {
	const [form] = Form.useForm();

	const record = {
		topic: 'from_server/#',
		qos: 0,
	};

	const onFinish = (values) => {
		const withQos = values
		withQos.qos = record.qos
		sub(withQos);
	};

	const handleUnsub = () => {
		const values = form.getFieldsValue();
		unSub(values);
	};

	const SubForm = (
		<Form
			layout="vertical"
			name="basic"
			form={form}
			initialValues={record}
			onFinish={onFinish}
		>
			<Row gutter={20}>
				<Col span={8}>
					<Form.Item
						label="Topic"
						name="topic"
					>
						<Input />
					</Form.Item>
				</Col>
			</Row>
			<Row>
				<Col span={8} >
					<Form.Item>
						<Button type="primary" htmlType="submit">
							Subscribe
						</Button>
						{
							showUnsub ?
								<Button type="danger" style={{ marginLeft: '10px' }} onClick={handleUnsub}>
									Unsubscribe
								</Button>
								: null
						}
					</Form.Item>
				</Col>
			</Row>
		</Form>
	)

	return (
		<Card >
			{SubForm}
		</Card>
	);
}

export default Subscriber;
