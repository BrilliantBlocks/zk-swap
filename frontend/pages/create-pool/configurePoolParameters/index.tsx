import React, { useState, useEffect } from 'react'
import styles from './Configure.module.css'
import { Typography } from '@mui/material'
import { Box } from '@mui/system'
import { TbArrowUpRight } from 'react-icons/tb'
import { FilledInputField } from '../formFields/filledInputField'
import { LabelFilledInput } from '../../../components/Dashboard/create-pool/LabelFilledInputField'

export interface InputProps {
	price: string
	delta: string
	asset: string
}
export type StartPrice = 'Buy NFTs with tokens' | 'Sell NFTs for tokens'

const PoolParameters = (props: any) => {
	const {
		formField: { startPrice, deltaAmount, assetAmount }
	} = props

	const [values, setValues] = useState<InputProps>({
		price: '',
		delta: '',
		asset: ''
	})
	const [totalPrice, setTotalPrice] = useState(0)

	const handleChange = (prop: keyof InputProps) => (event: React.ChangeEvent<HTMLInputElement>) => {
		setValues({ ...values, [prop]: event.target.value })
	}

	const calculateTotalPrice = () => {
		let totalPrice = Number(values.price) * Number(values.asset) + Number(values.delta) * (Number(values.asset) - 1) * Number(values.asset) / 2
		setTotalPrice(totalPrice)
	}

	useEffect(() => {
		if (values.price != '' && values.delta != '' && values.asset != '') {
			calculateTotalPrice()
		}
	}, [values])


	return (
		<>
			<Box className={styles.wrapper}>
				<Box className={styles.container}>
					<Box className={`${styles.container_row} ${styles.content}`}>
						<Box className={styles.spacing_y}>
							<Typography className={styles.headline} align="center">
								{' '}
								Pool Pricing
							</Typography>
							<Typography className={styles.subheading} align="center">
								{' '}
								Set the initial price and how your pool's price changes.
							</Typography>
						</Box>
						<LabelFilledInput label="Start Price" tooltipText="The Start price means ...." />
						<FilledInputField name={startPrice.name} text="ETH" value={values.price} onChange={handleChange('price')} />
						<Box className={styles.btn}>
							<Typography className={`${styles.btn_content} ${styles.bold}`}>
								{' '}
								Bonding Curve ( &nbsp;{' '}
								<span className={styles.icon_arrow}>
									<TbArrowUpRight size={20} />
								</span>{' '}
								&nbsp; Linear Curve)
							</Typography>
						</Box>
						<LabelFilledInput label="Delta" tooltipText="The amount you place as Delta will..." />
						<FilledInputField name={deltaAmount.name} text="ETH" value={values.delta} onChange={handleChange('delta')} />
						<Box className={styles.spacing_y}>
							<Typography className={styles.pool_info}>
								{' '}
								You have selected a starting price of <span className={styles.bold}>{values.price}</span> ETH
							</Typography>
							<Typography className={styles.pool_info}>
								{' '}
								Each time your pool sells an NFT, your sell price will adjust up to <span className={styles.bold}>{values.delta} ETH</span>
							</Typography>
						</Box>
					</Box>
					<Box className={`${styles.container_row} ${styles.content}`}>
						<Box className={styles.spacing_y}>
							<Typography className={styles.headline} align="center">
								{' '}
								Asset Amount
							</Typography>
							<Typography className={styles.subheading} align="center">
								{' '}
								Set how many NFTs you deposit into the pool.
							</Typography>
						</Box>
						<Box className={`${styles.assets_container} ${styles.column}`}>
							<Box className={styles.assets_container}>
								<Typography variant="body1" className={styles.asset_headline}>
									If you want to sell{' '}
								</Typography>
								<FilledInputField name={assetAmount.name} text="" value={values.asset} onChange={handleChange('asset')} />
							</Box>
							<Typography className={styles.asset_headline}>
								you will earn <span className={styles.bold}>{totalPrice}</span> ETH in total.{' '}
							</Typography> 
						</Box>
					</Box>
				</Box>
			</Box>
		</>
	)
}
export default PoolParameters
