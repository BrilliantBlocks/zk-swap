import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';
import { FormControl, Typography } from '@mui/material'
import { Box } from '@mui/material'
import Button from '@mui/material/Button'
import DialogContent from '@mui/material/DialogContent';
import styles from '../../pages/create-pool/selectAssets/SelectAssets.module.css'
import React from 'react';

interface CustomModalProps {
    open: boolean;
    handleClose: (event: React.SyntheticEvent) => void;
    title: string;
    subtitle?: string;
    children: React.ReactNode
    onClick: any
    bgColor?: string
    headline?: string
}

const CustomModal: React.FC<CustomModalProps> = (props): React.ReactElement => {

    return (
        <>
            <Dialog disableEscapeKeyDown
                open={props.open}
                onClose={props.handleClose}>
                <Box sx={{ backgroundColor: props.bgColor }}>
                    <DialogTitle className={styles.light} align="center" sx={{ fontSize: props.headline }}>{props.title}
                        <Button className={styles.dialogCloseButton} onClick={props.onClick}>X</Button>
                    </DialogTitle>
                    <DialogContent>
                        {props.subtitle && <Box component="form" className={styles.dialogModal}>
                            <Typography className={styles.dialogInformation}>{props.subtitle}</Typography>
                        </Box>}
                        <FormControl className={styles.dialogForm}>
                            {props.children}
                        </FormControl>
                    </DialogContent>
                </Box>
            </Dialog>
        </>
    )
}

export default CustomModal