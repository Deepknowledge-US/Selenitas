import React from 'react';

import { Layout }     from 'antd';
import HeaderContent  from './../Header/Header'
import BodyContent    from './../Body/Body'
import FooterContent  from './../Footer/Footer'
import SidebarContent from './../Sidebar/Sidebar'

import 'antd/dist/antd.css';

function Page (props) {
    return (
        <Layout style={{ minHeight: '100vh' }} >
            <SidebarContent />
            <Layout className="site-layout">
                <HeaderContent />
                <BodyContent />
                <FooterContent />
            </Layout>
        </Layout> 
    );
}

export default Page;