import React from 'react'
import { Typography, Divider } from '@mui/material'
import { Box } from '@mui/material'
import styles from '../../../pages/create-pool/pool-preview/PoolPreview.module.css'
import PrimaryButton from '../../PrimaryButton'
import CustomModal from '../../Modals/CustomDialog'

interface ModalEditProps {
    buttonTitle: string
}

export const ModalConfirm: React.FC<ModalEditProps> = (props): React.ReactElement => {
    const [openEdit, setOpenEdit] = React.useState(false)

    const handleOpen = () => {
        setOpenEdit(true)
    }
    const handleClose = () => {
        setOpenEdit(false);
    };

    return (
        <>
            <PrimaryButton onClick={handleOpen} backgroundColor='#141414' className={styles.btn} >
                {props.buttonTitle}
            </PrimaryButton>
            <CustomModal open={openEdit} handleClose={handleClose} title={`Confirm ${props.buttonTitle}`} onClick={handleClose} bgColor={'#292929'} headline={'1.4rem'}>
                <Divider className={styles.divider} />
                <Box className={styles.spacing_1}>
                    <Typography className={styles.dialog_headlines_confirm}>Are you sure you want to {props.buttonTitle} the selected NFTs?</Typography>
                </Box>
                <Box className={styles.dialog_btn_container_confirm}>
                    <PrimaryButton backgroundColor='#fac079' className={`${styles.btn} ${styles.dark_text} ${styles.btn_y_border}`} onClick={handleClose}>Confirm</PrimaryButton>
                    <PrimaryButton backgroundColor='transparent' className={`${styles.btn} ${styles.btn_y_border}`} onClick={handleClose}>Cancel</PrimaryButton>
                </Box>
            </CustomModal>
        </>
    );
}