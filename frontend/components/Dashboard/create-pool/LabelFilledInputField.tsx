import React from 'react'
import { Typography, Box, IconButton, Tooltip } from '@mui/material'
import InfoIcon from '@mui/icons-material/Info';
import styles from '../../../pages/create-pool/configurePoolParameters/Configure.module.css'

interface LabelFilledInputProps {
    label: string;
    tooltipText: string
}

export const LabelFilledInput: React.FC<LabelFilledInputProps> = (props): React.ReactElement => {
    return (
        <>
            <Box className={styles.label_container}>
                <Typography className={styles.label}>{props.label}</Typography>
                <Tooltip title={props.tooltipText} placement="right">
                    <IconButton><div className={styles.light}><InfoIcon /></div></IconButton>
                </Tooltip>
            </Box>
        </>
    );
}