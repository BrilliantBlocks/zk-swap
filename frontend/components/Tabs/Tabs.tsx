import * as React from 'react';
import { useState } from 'react';
import styles from './InputButton.module.css'
import Tab from '@mui/material/Tab';
import Box from '@mui/material/Box';
import TabContext from '@mui/lab/TabContext';
import StyledTabs from './StyledTabs';
import TabPanel from '@mui/lab/TabPanel';

import TabsLabel from './TabsLabel';
import BuyCard from '../Card/BuyCard';

enum CollectionTabType {
    Buy = 'buy',
    Sell = 'sell'
}

interface CollectionTabsProps {
    name?: CollectionTabType
    children?: React.ReactNode
    key: string
    cartItems: any
    item: any
    handleAddToCart: any
    buyArrLenght: any
}


const CollectionTabs: React.FC<CollectionTabsProps> = (props) => {
    const [value, setValue] = useState("");

    const handleChangeValue = (event: React.SyntheticEvent, newValue: string) => {
        setValue(newValue);
    };
    return (
        <Box className={styles.flex}>
            <TabContext value={value}>
                <Box sx={{ borderBottom: 1, borderColor: 'divider', display: 'flex', flexDirection: 'column' }}>
                    <StyledTabs onChange={handleChangeValue} aria-label="lab API tabs example" >
                        <Tab label={<><TabsLabel name='Buy' value={props.buyArrLenght} /></>} value='buy' className={`${styles.flex} ${styles.margin_right}`} />
                        <Tab label={<><TabsLabel name='Sell' value={0} /></>} value='sell' className={styles.flex} />
                    </StyledTabs>
                </Box>
                <Box>
                    <TabPanel value='buy'>
                        <BuyCard key={props.key} item={props.item} cartItems={props.cartItems} handleAddToCart={props.handleAddToCart} />
                    </TabPanel>
                    <TabPanel value='sell'>
                        <BuyCard key={props.key} item={props.item} cartItems={props.cartItems} handleAddToCart={props.handleAddToCart} />
                    </TabPanel>
                </Box>
            </TabContext>
        </Box>
    );
}
export default CollectionTabs