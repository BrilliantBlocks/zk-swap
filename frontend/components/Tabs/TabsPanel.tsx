import * as React from 'react';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';

interface TabPanelProps {
    children?: React.ReactNode;
    value: string;
}

function TabPanel(props: TabPanelProps) {
    const { children, value, ...other } = props;

    return (
        <div
            role="tabpanel"
            {...other}
        >
            <Box sx={{ p: 3 }}>
                <Typography>{children}</Typography>
            </Box>

        </div>
    );
}
export default TabPanel