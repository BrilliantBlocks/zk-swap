import React, { useState } from 'react'
import { Button, Divider } from '@mui/material'
import { Box } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import PrimaryButton from '../../PrimaryButton'
import CustomModal from '../../Modals/CustomDialog'
import ModalInput from './Input'
import { depositETH, withdrawETH } from '../../../services/wallet.service'

interface ModalTokenProps {
    title: string
    poolAddress: string
}

export const ModalToken: React.FC<ModalTokenProps> = (props): React.ReactElement => {
    const [openEdit, setOpenEdit] = React.useState(false)
    const [amount, setAmount] = useState('')

    const handleOpen = () => {
        setOpenEdit(true)
    }
    const handleClose = () => {
        setOpenEdit(false);
        setAmount('')
    };
    const handleConfirmDeposit = () => {
        depositETH(props.poolAddress, Number(amount))
        setOpenEdit(false)
        setAmount('')
    }

    const handleConfirmWithdraw = () => {
        withdrawETH(props.poolAddress, Number(amount))
        setOpenEdit(false)
        setAmount('')
    }
    const handleAmountUpdate = (event: any) => {
        setAmount(event.target.value)
    }
    return (
        <>
            <PrimaryButton onClick={handleOpen} backgroundColor='#141414' className={styles.btn} >
                {props.title} ERC20
            </PrimaryButton>
            <CustomModal open={openEdit} handleClose={handleClose} title={`Confirm ${props.title}`} onClick={handleClose} bgColor={'#292929'} headline={'1.4rem'}>
                <Divider className={styles.divider} />
                <Box className={styles.spacing_1}>
                    <ModalInput label={`Enter The Amount Of ERC20 Tokens You Want To ${props.title}`} value={amount} onChange={handleAmountUpdate} />
                </Box>
                <Box className={styles.dialog_btn_container_confirm}>
                    {props.title === 'Deposit' ?
                        <Button variant='contained' color='secondary' className={`${styles.btn} ${styles.dark_text} ${styles.btn_y_border} ${styles.padding_x}`} onClick={() => handleConfirmDeposit()}>Confirm</Button>
                        :
                        <Button variant='contained' color='secondary' className={`${styles.btn} ${styles.dark_text} ${styles.btn_y_border} ${styles.padding_x}`} onClick={() => handleConfirmWithdraw()}>Confirm</Button>
                    }
                    <PrimaryButton backgroundColor='transparent' className={`${styles.btn} ${styles.btn_y_border}`} onClick={handleClose}>Cancel</PrimaryButton>
                </Box>
            </CustomModal>
        </>
    );
}