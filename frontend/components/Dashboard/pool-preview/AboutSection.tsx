import React, { useEffect, useState } from 'react'
import { Box, Typography } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import PoolOwnerLinks from './PoolOwnerLinks'
import { walletAddress } from '../../../services/wallet.service'

interface AboutPoolProps {

    startPrice: number
    deltaAmount: number
}

const AboutPool: React.FC<AboutPoolProps> = (props: any): React.ReactElement => {
    const [accountAddress, setAccountAddress] = useState<any>('')

    useEffect(() => {
        walletAddress()
            .then((address) => {
                setAccountAddress(address)
            })


    }, [accountAddress])
    return (
        <>
            <Box className={`${styles.card_item_bottom} ${styles.bg}`}>
                <Typography variant='h2' className={styles.headline}>About</Typography>
                <Box className={styles.pool_owner_card}>
                    <Typography className={styles.pool_owner_headline}>Pool Owner:</Typography>
                    <PoolOwnerLinks owner={accountAddress} />
                </Box>
                <Box className={styles.spacing}>
                    <Typography className={styles.text}>Right now this pool will sell at <span className={styles.bold}>{props.startPrice} ERC20</span> and will buy at <span className={styles.bold}>{props.startPrice} ERC20</span></Typography>
                </Box>
                <Box className={styles.spacing}>
                    <Typography className={styles.text}>Each time this pool buys/sells an NFT, the price will be lowered/increased by <span className={styles.bold}>{props.deltaAmount} ERC20</span></Typography>
                </Box>
                <Box className={styles.spacing}>
                    <Typography className={styles.text}>Each time someone swaps with this pool, you will earn <span className={styles.bold}>5%</span> of the swap amount as swap fee. </Typography>
                </Box>
            </Box>
        </>
    )
}

export default AboutPool