import React from 'react'
import { Typography } from '@mui/material'
import { Box } from '@mui/material'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import FormControl from '@mui/material/FormControl'
import MenuItem from '@mui/material/MenuItem'
import Input from '@mui/material/Input'
import Image from 'next/image'
import eth from '../assets/images/eth-logo.png'
import styles from '../../../pages/create-pool/selectAssets/SelectAssets.module.css'
import PrimaryButton from '../../PrimaryButton'

const AssetCard: React.FC = (props: any): React.ReactElement => {
    const [openDeposit, setOpenDeposit] = React.useState(false)
    const [openReceive, setOpenReceive] = React.useState(false)

    const handleOpenDeposit = () => {
        setOpenDeposit(true)
    }

    const handleOpenReceive = () => {
        setOpenReceive(true)
    }

    const handleClose = (event: React.SyntheticEvent<unknown>, reason?: string) => {
        if (reason !== 'backdropClick') {
            setOpenDeposit(false)
            setOpenReceive(false)
        }
    }

    return (
        <>
            <Box className={styles.content}>
                <Typography className={styles.subheading}>
                    deposit
                    <PrimaryButton onClick={handleOpenDeposit} backgroundColor='transparent' className={styles.btn} >
                        Select token
                    </PrimaryButton>
                    <Dialog disableEscapeKeyDown open={openDeposit} onClose={handleClose}>
                        <DialogTitle className={styles.light} align="center">
                            Select token
                            <Button className={styles.dialogCloseButton} onClick={handleClose}>
                                X
                            </Button>
                        </DialogTitle>
                        <DialogContent>
                            <Box component="form" className={styles.dialogModal}>
                                <Typography className={styles.dialogInformation}>Only eth is currently enabled.</Typography>
                                <FormControl className={styles.dialogForm}>
                                    <MenuItem className={styles.depositMenuItem}>
                                        <Box className={styles.depositMenuItemBox}>
                                            <Box className={styles.depositMenuItemBoxImage}>
                                                <Image src={eth} width={20} height={20} />
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
                                </FormControl>
                            </Box>
                        </DialogContent>
                    </Dialog>
                </Typography>
            </Box>
            <Typography className={styles.headline}>and...</Typography>
            <Box className={styles.content}>
                <Typography className={styles.subheading}>
                    receive
                    <PrimaryButton onClick={handleOpenReceive} backgroundColor='transparent' className={styles.btn} >
                        Select NFT
                    </PrimaryButton>
                    <Dialog disableEscapeKeyDown open={openReceive} onClose={handleClose}>
                        <DialogTitle className={styles.light} align="center">
                            Select NFT
                            <Button className={styles.dialogCloseButton} onClick={handleClose}>
                                X
                            </Button>
                        </DialogTitle>
                        <DialogContent>
                            <Box component="form" className={styles.dialogModal}>
                                <Typography className={styles.dialogInformation}>Please select one NFT</Typography>
                                <FormControl className={styles.dialogForm} variant="standard">
                                    <Input placeholder="Search name, symbol, or paste address for custom token" className={styles.input}></Input>
                                </FormControl>
                            </Box>
                        </DialogContent>
                    </Dialog>
                </Typography>
            </Box>
        </>
    );
};
export default AssetCard