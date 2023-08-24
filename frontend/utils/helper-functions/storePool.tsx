import toast from 'react-hot-toast'
import { ETHAddress } from '../manuallyDefinedValues'

export interface PoolProps {
	id: string
	owner: string | undefined
	transactionHash: string
	paramsTransactionHash: string
	collectionTransactionHash: string
	poolAddress: string
	collectionAddress: string
	startPrice: string
	deltaAmount: string
	poolType: string
	ethAddress: typeof ETHAddress
}

export function storePool(pool: PoolProps) {
	console.log('store', pool)
	try {
		const createdPools = localStorage.getItem('pool')

		if (createdPools) {
			const poolsPreview: PoolProps[] = JSON.parse(createdPools) || []

			poolsPreview.push(pool)
			localStorage.setItem('pool', JSON.stringify(poolsPreview))
		} else {
			localStorage.setItem('pool', JSON.stringify([pool]))
		}
	} catch (error) {
		toast.error("Can't create a pool , please try again later")
	}
}
