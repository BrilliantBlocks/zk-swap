import React, { useEffect } from 'react'
import { Typography, Box } from '@mui/material'
import { PoolTypeField } from '../formFields'
import styles from './PoolType.module.css'
import { useFormikContext } from 'formik'

export type PoolType = 'Buy NFTs with tokens' | 'Sell NFTs for tokens'

const SelectPoolType = (props: any) => {
	const {
		formField: { poolType }
	} = props
	const [isActive, setIsActive] = React.useState(false)
	const [isActiveSell, setIsActiveSell] = React.useState(false)
	const { values } = useFormikContext<{ poolType: PoolType }>()

	useEffect(() => {
		props.onPoolTypeUpdate(values.poolType)
	}, [values.poolType])

	const handleChangeBorderBuy = () => {
		setIsActive(true)
		setIsActiveSell(false)
	}
	const handleChangeBorderSell = () => {
		setIsActive(false)
		setIsActiveSell(true)
	}

	return (
		<Box className={styles.content}>
			<Typography align="center" variant="h2" className={styles.headline}>
				I want to...
			</Typography>
			<Box className={styles.containerBox}>
				<PoolTypeField
					name={poolType.name}
					value="Buy NFTs with tokens"
					label="You will deposit tokens and receive NFTs as people swap their NFTs for your deposited tokens."
					onClick={handleChangeBorderBuy}
					className={isActive ? `${styles.childBox} ${styles.border}` : `${styles.childBox}`}
				/>
				<PoolTypeField
					name={poolType.name}
					value="Sell NFTs for tokens"
					label="You will deposit NFTs and receive tokens as people swap their tokens for your deposited NFTs."
					onClick={handleChangeBorderSell}
					className={isActiveSell ? `${styles.childBox} ${styles.border}` : `${styles.childBox}`}
				/>
			</Box>
		</Box>
	)
}

export default SelectPoolType
