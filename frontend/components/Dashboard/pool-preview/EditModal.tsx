import React, { useEffect } from 'react'
import { Typography, Divider } from '@mui/material'
import { Box } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import PrimaryButton from '../../PrimaryButton'
import CustomModal from '../../Modals/CustomDialog'
import ModalInput from './Input'
import { PoolProps, storePool } from '../../../utils/helper-functions/storePool'
import toast from 'react-hot-toast'
import { ETHAddress } from '../../../utils/manuallyDefinedValues'

interface ModalEditProps {
	bgColor: string
	border?: string
	className?: string
	buttonTitle?: string
	startPrice?: any
	poolAddress?: string
	collectionAddress?: string
	transactionHash?: string
	paramsTransactionHash?: string
	collectionTransactionHash?: string
	ethAddress?: typeof ETHAddress
	poolType?: string
	deltaAmount?: string
	id?: string
	onChange?: (e: any) => void
	value?: any
	onClick?: () => void
}

export const ModalEdit: React.FC<ModalEditProps> = (props): React.ReactElement => {
	const [openEdit, setOpenEdit] = React.useState(false)
	const [localPool, setLocalPool] = React.useState<PoolProps | undefined>(undefined)
	const [startPrice, setUpdateStartPrice] = React.useState<any>(props.startPrice)
	const [deltaAmount, setDeltaAmount] = React.useState<any>(props.deltaAmount)
	const [transactionHash, setTransactionHash] = React.useState<any>(props.transactionHash)
	const [paramsTransactionHash, setParamsTransactionHash] = React.useState<any>(props.paramsTransactionHash)
	const [collectionTransactionHash, setCollectionTransactionHash] = React.useState<any>(props.collectionTransactionHash)
	const [poolAddress, setPoolAddress] = React.useState<any>(props.poolAddress)
	const [collectionAddress, setCollectionAddress] = React.useState<any>(props.collectionAddress)
	const [ethAddress, setEthAddress] = React.useState<any>(props.ethAddress)
	const [poolType, setPoolType] = React.useState<any>(props.poolType)
	const [poolID, setPoolID] = React.useState<any>(props.id)

	const handleOpen = () => {
		setOpenEdit(true)
		setPoolID(props.id)
	}
	const handleClose = () => {
		setOpenEdit(false)
		setPoolID(undefined)
		window.location.reload()
	}

	const handleCurrentPrice = (event: any) => {
		setUpdateStartPrice(event.target.value)
	}

	const handleDeltaAmount = (event: any) => {
		setDeltaAmount(event.target.value)
	}

	useEffect(() => {
		const getPoolParams = localStorage.getItem('pool') || '[]'
		var data = JSON.parse(getPoolParams) || []

		data.forEach((item: PoolProps) => {
			if (item?.id === poolID) {
				const { owner } = item
				const id = poolID
				setLocalPool({
					id,
					owner,
					poolType,
					transactionHash,
					paramsTransactionHash,
					collectionTransactionHash,
					poolAddress,
					collectionAddress,
					startPrice,
					deltaAmount,
					ethAddress
				})
				return
			}
		})
	}, [poolID])

	const updatePool = async (event: any): Promise<void> => {
		event.preventDefault()
		try {
			if (localPool) {
				storePool({ ...localPool, startPrice: startPrice, deltaAmount: deltaAmount, })

				const getPoolParams = localStorage.getItem('pool') || '[]'
				let data = JSON.parse(getPoolParams)
				for (var i = 0; i < data.length; i++) {
					if (data[i].id == localPool.id) {
						data.splice(i, 1)
						localStorage.removeItem('pool')
						localStorage.setItem('pool', JSON.stringify(data))
					}
				}
				toast.success('Successfully updated your pool')
			}
		} catch (error) {
			toast.error('There is a connection problem at the moment, please try again later')
		}
	}

	return (
		<>
			<PrimaryButton onClick={handleOpen} backgroundColor={props.bgColor} border={props.border} className={props.className}>
				{props.buttonTitle}
			</PrimaryButton>
			<CustomModal open={openEdit} handleClose={handleClose} title="Edit Pricing" onClick={handleClose} bgColor={'#292929'} headline={'1.4rem'}>
				<Divider className={styles.divider} />
				<>
					<ModalInput label="Current Price: " label_number={`${props.startPrice} ETH`} value={props.startPrice} onChange={handleCurrentPrice} />
					<ModalInput label="Current Delta:" label_number={`${props.deltaAmount} ETH`} value={props.deltaAmount} onChange={handleDeltaAmount} />
				</>
				<Box className={styles.spacing}>
					<Typography className={styles.text}>After updating your pool pricing with the above changes:</Typography>
					<Typography className={`${styles.text} ${styles.color_gray}`}>
						Your pool will sell at <span className={`${styles.bold} ${styles.color_white}`}> {props.startPrice}</span> ETH and will buy at{' '}
						<span className={`${styles.bold} ${styles.color_white}`}>0.2929</span> ETH.
					</Typography>
					<Typography className={`${styles.text} ${styles.color_gray}`}>
						Each time your pool buys/sells an NFT, your price will adjust{' '}
						<span className={`${styles.bold} ${styles.color_white}`}>{props.deltaAmount} ETH</span> down/up.
					</Typography>
					<Typography className={`${styles.text} ${styles.color_gray}`}>
						Each time someone swaps with your pool, you will earn <span className={`${styles.bold} ${styles.color_white}`}>5%</span> of the swap
						amount as swap fee.
					</Typography>
				</Box>
				<Box className={styles.dialog_btn_container}>
					<PrimaryButton backgroundColor="#fac079" className={`${styles.btn} ${styles.dark_text} ${styles.btn_y_border}`} onClick={updatePool}>
						Update
					</PrimaryButton>
				</Box>
			</CustomModal>
		</>
	)
}
