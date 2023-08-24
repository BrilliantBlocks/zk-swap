import * as React from 'react';
import { styled } from '@mui/material/styles';
import TabList from '@mui/lab/TabList';

interface StyledTabsProps {
    children?: React.ReactNode;
    onChange: (event: React.SyntheticEvent, newValue: string) => void;
}

const StyledTabs = styled((props: StyledTabsProps) => (
    <TabList
        {...props}
        TabIndicatorProps={{ children: <span className="MuiTabs-indicatorSpan" /> }}
    />

))({
    '& .MuiTabs-indicator': {
        display: 'flex',
        justifyContent: 'center',
        backgroundColor: 'transparent',
    },
    '& .MuiTabs-indicatorSpan': {
        maxWidth: 80,
        width: '100%',
        backgroundColor: '#fff',
    },
});

export default StyledTabs