import styles from './Pools.module.css'
import { Box } from '@mui/material'
import Heading from '../../components/Heading'
import SwitchBtn from '../../components/Switch/Switch'
import AddIcon from '@mui/icons-material/Add'
import PoolsCard from '../../components/Card/PoolsCard'
import Link from 'next/link'
import PrimaryButton from '../../components/PrimaryButton'
import { PoolProps, storePool } from '../../utils/helper-functions/storePool'
import { useEffect, useState } from 'react'
import { fetchEvents } from '../../services/wallet.service'

const savePool = async (item: PoolProps) => {
	const Events: any = await fetchEvents(item.transactionHash, item.id)
	const poolAddress = Events[0].poolAddress
	const poolId = Events[0].poolId

	if (item.id === poolId) {
		const {
			id,
			owner,
			poolType,
			startPrice,
			collectionAddress,
			transactionHash,
			deltaAmount,
			ethAddress: ethAddress,
			paramsTransactionHash,
			collectionTransactionHash
		} = item
		storePool({
			id,
			owner,
			poolType,
			poolAddress,
			collectionAddress,
			transactionHash,
			startPrice,
			deltaAmount,
			ethAddress: ethAddress,
			paramsTransactionHash,
			collectionTransactionHash
		})

		const getPoolParams = localStorage.getItem('pool') || '[]'
		let data = JSON.parse(getPoolParams)

		for (var i = 0; i < data.length; i++) {
			if (data[i]?.id === item.id) {
				data.splice(i, 1)
				localStorage.removeItem('pool')
				localStorage.setItem('pool', JSON.stringify(data))
				break
			}
		}
	}
}

const PoolsPage = () => {
	const [pool, setPool] = useState<PoolProps[]>([])

	useEffect(() => {
		const getPoolParams = localStorage.getItem('pool') || '[]'
		let data = JSON.parse(getPoolParams)
		setPool(data || [])
	}, [])

	useEffect(() => {
		pool.forEach(async (item: PoolProps) => {
			if (item?.poolAddress === '' && item?.transactionHash !== '') {
				await savePool(item)
			}
		})
	}, [pool.length])

	return (
		<>
			<Box className={styles.pools_container}>
				<Heading>Your Pools</Heading>
				<Box className={styles.pools_content_t}>
					<SwitchBtn label="Hide empty pools." />
				</Box>
				<Box className={styles.btn_container}>
					<Link href="create-pool" passHref>
						<a>
							<PrimaryButton backgroundColor="#fac079" border={'3px solid #F5B700'} startIcon={<AddIcon />}>
								Create New Pool
							</PrimaryButton>
						</a>
					</Link>
				</Box>
			</Box>
			<Box className={styles.pools_content_b}>
				<Box className={styles.pools_content_card}>
					<Box className={styles.spacing}>
					</Box>
					{pool.map((item: PoolProps, key: any) => (item != null ? (
						<PoolsCard
							id={item.id}
							owner={item.owner}
							startPrice={item.startPrice}
							deltaAmount={item.deltaAmount}
							poolType={item.poolType}
							key={key}
							transactionHash={item.transactionHash}
							paramsTransactionHash={item.paramsTransactionHash}
							collectionTransactionHash={item.collectionTransactionHash}
							poolAddress={item.poolAddress}
							collectionAddress={item.collectionAddress}
							ethAddress={item.ethAddress}
						/>
					) : ''))}
				</Box>
			</Box>
		</>
	)
}

export default PoolsPage
