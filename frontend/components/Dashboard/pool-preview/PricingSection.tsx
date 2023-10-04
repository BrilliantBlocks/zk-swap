import React from 'react'
import { Box, Typography } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import { TbArrowUpRight } from 'react-icons/tb'

interface PricingPoolProps {
    startPrice: number
    deltaAmount: number
}

const PricingPool: React.FC<PricingPoolProps> = ({ startPrice, deltaAmount }): React.ReactElement => {

    return (
        <>
            <Box className={`${styles.card_item_top} ${styles.bg}`}>
                <Box className={styles.cards_header_container}>
                    <Typography variant='h2' className={styles.headline}>Pricing</Typography>
                </Box>
                <Box className={styles.pricing_cards_container}>
                    <Box className={styles.card_content}>
                        <Typography variant='h6' className={styles.cards_heading}>Current Price</Typography>
                        <Typography variant='h6' className={styles.cards_heading_bold}>{startPrice} ERC20</Typography>
                    </Box>
                    <Box className={styles.card_content}>
                        <Box className={styles.flex}>
                            <Typography variant='h6' className={styles.cards_heading}>Delta</Typography>
                            <Box className={styles.cards_linear}>
                                <Typography variant='h6' className={styles.cards_heading_linear}>Linear</Typography>
                                <Box className={styles.icon}>
                                    <TbArrowUpRight size={20} />
                                </Box>
                            </Box>
                        </Box>
                        <Typography variant='h6' className={styles.cards_heading_bold}>{deltaAmount} ERC20</Typography>
                    </Box>
                    <Box className={styles.card_content}>
                        <Typography variant='h6' className={styles.cards_heading}>Swap Fee</Typography>
                        <Typography variant='h6' className={styles.cards_heading_bold}>5%</Typography>
                    </Box>
                </Box>
            </Box>
        </>
    )
}

export default PricingPool