import React from 'react'
import { Typography } from '@mui/material'
import { Box } from '@mui/material'
import MenuItem from '@mui/material/MenuItem'
import styles from '../../../pages/create-pool/selectAssets/SelectAssets.module.css'
import PrimaryButton from '../../PrimaryButton'
import Image from 'next/image'
import eth from '../../assets/images/eth-logo.png'
import CustomModal from '../../Modals/CustomDialog'

export const ModalEth: React.FC = (props: any): React.ReactElement => {
    const [openDeposit, setOpenDeposit] = React.useState(false)
    const [selectedValue, setSelectedValue] = React.useState('');

    const handleOpenDeposit = () => {
        setOpenDeposit(true)
    }
    const handleCloseBtn = (event: React.SyntheticEvent<unknown>, reason?: string) => {
        if (reason !== 'backdropClick') {
            setOpenDeposit(false)
        }
    }
    const handleClose = (value: string) => {
        setOpenDeposit(false);
        setSelectedValue(value);
    };
    const handleListItemClick = (value: string) => {
        handleClose(value);
    };

    return (
        <>
            <PrimaryButton onClick={handleOpenDeposit} backgroundColor='transparent' className={styles.btn} >
                {selectedValue ? `${selectedValue}` : 'Select token'}
            </PrimaryButton>
            <CustomModal open={openDeposit} handleClose={handleCloseBtn} title='Select token' subtitle='Only eth Token is currently enabled.' onClick={handleCloseBtn}>
                <MenuItem className={styles.depositMenuItem}>
                    <Box className={styles.depositMenuItemBox} onClick={() => handleListItemClick('eth')} >
                        <Box className={styles.depositMenuItemBoxImage}>
                            <Image src={eth} width={22} height={24} className={styles.rounded_img} />
                        </Box>
                        <Box className={styles.depositMenuItemBoxData}>
                            <Typography className={styles.noneTextTransfor}>Token</Typography>
                            <Typography className={`${styles.boldText} ${styles.fontSize16}`}>eth</Typography>
                        </Box>
                        <Box className={styles.priceData}>
                            <Typography className={styles.textCenter}>0.000</Typography>
                        </Box>
                    </Box>
                </MenuItem>
            </CustomModal>
        </>
    );
}