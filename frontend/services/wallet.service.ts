import { BondingCurveClassHash } from './../utils/manuallyDefinedValues'
import { connect, IStarknetWindowObject } from '@argent/get-starknet'
import { constants, shortString, RpcProvider, hash } from 'starknet'
import { Network } from './token.service'
import { PoolFactoryRootAddress, StarknetRPCNode, ETHAddress } from '../utils/manuallyDefinedValues'
import Web3 from 'web3'
import { toast } from 'react-hot-toast'
import { PoolProps, storePool } from '../utils/helper-functions/storePool'
import { NFT } from '../components/Dashboard/pool-preview/SelectModal'
import { TableCollection } from '../pages'

const rpcProvider = new RpcProvider({
	nodeUrl: StarknetRPCNode
})

let starknet: IStarknetWindowObject | undefined = undefined

export const initStarknet = async () => {
	if (starknet && starknet.isConnected) {
		return starknet
	}

	await connect({ showList: false, include: ['argentX'] }).then(async (s) => {
		starknet = s

		if (starknet) {
			await starknet.enable()
		}
	})

	return starknet
}

export const checkWalletisConnected = async () => {
	await initStarknet()

	return starknet && starknet.isConnected
}

export const silentConnectWallet = async () => {
	await initStarknet()

	if (!starknet?.isConnected) {
		await starknet?.enable({ showModal: true })
	}

	return starknet
}

export const connectWallet = async () => {
	const windowStarknet = await connect({
		include: ['argentX']
	})

	await windowStarknet?.enable()

	return windowStarknet
}

export const walletAddress = async (): Promise<[string | undefined, string?]> => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return [undefined, 'Starknet wallet not connected'];
	}

	return [starknet?.selectedAddress, undefined];
}

export const networkId = async (): Promise<Network | undefined> => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return
	}

	try {
		const { chainId } = starknet.provider
		if (chainId === constants.StarknetChainId.MAINNET) {
			return 'mainnet-alpha'
		} else if (chainId === constants.StarknetChainId.TESTNET) {
			return 'goerli-alpha'
		} else {
			return 'localhost'
		}
	} catch {
		// TODO: create toast notification
	}
}

export const addToken = async (address: string): Promise<void> => {
	await initStarknet()

	if (!starknet?.isConnected) {
		throw Error('starknet wallet not connected')
	}
	await starknet.request({
		type: 'wallet_watchAsset',
		params: {
			type: 'ERC20',
			options: {
				address
			}
		}
	})
}

export const getExplorerBaseUrl = async (): Promise<string | undefined> => {
	await initStarknet()

	const network = await networkId()
	if (network === 'mainnet-alpha') {
		return 'https://voyager.online'
	} else if (network === 'goerli-alpha') {
		return 'https://goerli.voyager.online'
	}
}

export const chainId = async (): Promise<string | undefined> => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return undefined
	}

	return shortString.decodeShortString(starknet.provider.chainId)
}

export const signMessage = async (message: string) => {
	await initStarknet()

	if (!starknet?.isConnected) throw Error('Starknet wallet not connected')
	if (!shortString.isShortString(message)) {
		throw Error('Message must be a short string')
	}

	return starknet.account.signMessage({
		domain: {
			name: 'ZK-Swap',
			chainId: await networkId(),
			version: '0.0.1'
		},
		types: {
			StarkNetDomain: [
				{
					name: 'name',
					type: 'felt'
				},
				{
					name: 'chainId',
					type: 'felt'
				},
				{
					name: 'version',
					type: 'felt'
				}
			],
			Message: [
				{
					name: 'message',
					type: 'felt'
				}
			]
		},
		primaryType: 'Message',
		message: {
			message
		}
	})
}

export const waitForTransaction = async (hash: string) => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return
	}
	return starknet.provider.waitForTransaction(hash)
}

export const addWalletChangeListener = async (handleEvent: (accounts: string[]) => void) => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return
	}
	starknet.on('accountsChanged', handleEvent)
}

export const removeWalletChangeListener = async (handleEvent: (accounts: string[]) => void) => {
	await initStarknet()

	if (!starknet?.isConnected) {
		return
	}

	starknet.off('accountsChanged', handleEvent)
}

export const getAllCollectionsFromAllPools = async () => {
	await initStarknet()

	const data = await rpcProvider.callContract({
		contractAddress: PoolFactoryRootAddress,
		entrypoint: 'getAllCollectionsFromAllPools',
		calldata: []
	})
	data.result.splice(0, 1)
	console.log(`RESULT FROM get all collections from all pools:`, data.result)
	return data.result
}

// Unused
export const getCollection = async (poolAddress: string) => {
	await initStarknet()

	await rpcProvider
		.callContract({
			contractAddress: poolAddress,
			entrypoint: 'getAllCollections',
			calldata: []
		})
		.then((data) => {
			data.result.splice(0, 1)
			console.info(`Collections from suggested pool is: `, data.result)
		})
}

export const getNFTsOfCollection = async (poolAddress: string, collectionAddress: string): Promise<string[]> => {
	await initStarknet()

	const data = await rpcProvider.callContract({
		contractAddress: poolAddress,
		entrypoint: 'getAllNftsOfCollection',
		calldata: [collectionAddress]
	})

	let res = []
	res = data.result
	return res
}

export const getMetaData = async (collectionAddress: string, tokenArray: string[]): Promise<string> => {
	await initStarknet()

	const numberLow = Web3.utils.hexToNumberString(tokenArray[0])
	const numberHigh = Web3.utils.hexToNumberString(tokenArray[1])

	try {
		const data = await rpcProvider.callContract({
			contractAddress: collectionAddress,
			entrypoint: 'tokenURI',
			calldata: [numberLow, numberHigh]
		})

		data.result.splice(0, 1)

		let url = ''

		data.result.forEach((d) => {
			const utf8 = Web3.utils.hexToUtf8(d)

			url += utf8
		})

		return url
	} catch (error) {
		return ''
	}
}

export const getNameFromCollection = async (collectionAddress: string): Promise<string> => {
	await initStarknet()

	const data = await rpcProvider.callContract({
		contractAddress: collectionAddress,
		entrypoint: 'name',
		calldata: []
	})

	let name: string = ''

	data.result.forEach((item) => {
		const utf8 = Web3.utils.hexToUtf8(item)

		name += utf8
	})

	return name
}

export const getPoolConfig = async (poolAddress: any): Promise<{ price: number; delta: number }> => {
	await initStarknet()

	let price: number = 0
	let delta: number = 0

	const data = await rpcProvider.callContract({
		contractAddress: poolAddress,
		entrypoint: 'getPoolConfig',
		calldata: []
	})

	price = Number(data.result[0])
	delta = Number(data.result[2])

	return {
		price,
		delta
	}
}

export const withdrawETH = async (poolAddress: string, amount: number): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		await starknet.account.execute({
			contractAddress: poolAddress,
			entrypoint: 'withdrawEth',
			calldata: [`${amount}`, '0']
		})
	} else {
		toast.error('Starknet not connect')
	}
}

export const withdrawAllETH = async (poolAddress: string) => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		await starknet.account.execute({
			contractAddress: poolAddress,
			entrypoint: 'withdrawAllEth',
			calldata: []
		})
	} else {
		toast.error('Starknet not connect')
	}
}

export const withdrawNFT = async (poolAddress: string, collectionAddress: string, nfts: NFT[]): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	const calldata: (string | number)[] = [nfts.length]

	nfts.forEach((nft) => {
		calldata.push(...[collectionAddress, nft.TokenId, '0'])
	})

	if (starknet.isConnected === true) {
		await starknet.account.execute({
			contractAddress: poolAddress,
			entrypoint: 'removeNftFromPool',
			calldata
		})
	} else {
		toast.error('Starknet not connect')
	}
}

export const depositNFTs = async (poolAddress: string, collectionAddress: string, nfts: NFT[]): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		const tokenIds = nfts.map((nft) => nft.TokenId)
		const addNftCalldata: string[] = []

		tokenIds.forEach((tokenId) => {
			addNftCalldata.push(collectionAddress)
			addNftCalldata.push(tokenId)
			addNftCalldata.push('0')
		})

		const approvals: any[] = []

		tokenIds.forEach((tokenId) => {
			approvals.push({
				contractAddress: collectionAddress,
				entrypoint: 'approve',
				calldata: [poolAddress, tokenId, '0'] // Change tokenID to Uint256
			})
		})

		await starknet.account.execute([
			...approvals,
			{
				contractAddress: poolAddress,
				entrypoint: 'addNftToPool',
				calldata: [tokenIds.length, ...addNftCalldata]
			}
		])
	} else {
		toast.error('Starknet not connect')
	}
}

export const checkSupportedCollection = async (poolAddress: string, collectionAddress: string): Promise<boolean> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		toast.error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		const data: any = await rpcProvider.callContract({
			contractAddress: poolAddress,
			entrypoint: 'checkCollectionSupport',
			calldata: [collectionAddress]
		})

		return Web3.utils.hexToNumber(data.result[0]) === 1
	}

	return false
}

export const addSupportedCollections = async (poolAddress: string, collectionAddress: any): Promise<string> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		toast.error('Starknet wallet not connected')
	}

	const { transaction_hash } = await starknet.account.execute({
		contractAddress: poolAddress,
		entrypoint: 'addSupportedCollections',
		calldata: [1, collectionAddress]
	})

	return transaction_hash
}

export const depositETH = async (poolAddress: string, amount: any) => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		await starknet.account.execute([
			{
				contractAddress: ETHAddress,
				entrypoint: 'approve',
				calldata: [poolAddress, `${amount}`, '0']
			},
			{
				contractAddress: poolAddress,
				entrypoint: 'depositEth',
				calldata: [`${amount}`, '0']
			}
		])
	} else {
		toast.error('Starknet not connect')
	}
}

export const pausePool = async (PoolAddress: string): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	await starknet.account.execute({
		contractAddress: PoolAddress,
		entrypoint: 'togglePause',
		calldata: []
	})
}

export const isPoolPaused = async (PoolAddress: string): Promise<boolean> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		let result: any
		const data = await rpcProvider.callContract({
			contractAddress: PoolAddress,
			entrypoint: 'isPaused',
			calldata: []
		})

		result = Web3.utils.hexToNumber(data.result[0])

		return result === 1
	}

	return false
}

export const getPoolTypeClassHash = async (poolAddress: string): Promise<string> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		const data = await rpcProvider.callContract({
			contractAddress: PoolFactoryRootAddress,
			entrypoint: 'getPoolTypeClassHash',
			calldata: [poolAddress]
		})

		return data.result[0]
	}

	return ''
}

export const deployQueryPoolType = async (poolAddress: string) => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		await rpcProvider
			.callContract({
				contractAddress: PoolFactoryRootAddress,
				entrypoint: 'getPoolTypeClassHash',
				calldata: [poolAddress]
			})
			.then((data: any) => {
				let poolHashValue
				if (data.result === '0x1af0ceca401d249d0768483c8baf6a61801fe823603ffe74a3dd459bbf748d4') {
					poolHashValue = 'buypool'
				} else {
					poolHashValue = data.result
				}
			})
	} else {
		toast.error('Starknet not connect')
	}
}

export const fetchEvents = async (tsHash: string, poolId: string) => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	let poolAddress: string = ''

	if (starknet.isConnected === true) {
		const transaction: any = await starknet.account.getTransaction(tsHash)
		if (transaction.status === 'ACCEPTED_ON_L2') {
			await rpcProvider
				.getEvents({
					address: PoolFactoryRootAddress,
					chunk_size: 1024,
					from_block: { block_number: transaction.block_number } as any,
					to_block: { block_number: transaction.block_number } as any,
					keys: [hash.getSelectorFromName('DeployPool')],
				})
				.then((event: any) => {
					poolAddress = event.events[0].data[0]
				})
		}
	}
	return [{ poolAddress: poolAddress, poolId: poolId }]
}

export const deployPool = async (typeHash: string, poolId: string) => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	console.log(`Pool ID who you want deploy is: `, poolId)

	if (starknet.isConnected === false) {
		throw Error('Starknet wallet not connected')
	}

	if (starknet.isConnected === true) {
		const pool = await starknet.account.execute({
			contractAddress: PoolFactoryRootAddress,
			entrypoint: 'mint',
			calldata: [typeHash, BondingCurveClassHash, ETHAddress]
		})

		const getPoolParams = localStorage.getItem('pool') || '[]'
		var data = JSON.parse(getPoolParams) || []

		data.forEach((item: PoolProps) => {
			if (item?.id === poolId) {
				
				const transactionHash = pool.transaction_hash
				item.transactionHash = transactionHash
				localStorage.setItem('pool', JSON.stringify(data))
			}
		})

		await starknet.account.waitForTransaction(pool.transaction_hash)

		const transaction: any = await starknet.account.getTransaction(pool.transaction_hash)

		const interval = setInterval(async () => {
			const { events } = await rpcProvider.getEvents({
				address: PoolFactoryRootAddress,
				chunk_size: 1024,
				from_block: { block_number: transaction.block_number } as any,
				to_block: { block_number: transaction.block_number } as any,
				keys: [hash.getSelectorFromName('DeployPool')],
			})

			if (events.length > 0) {
				const eventData: string[] = (events[0] as any).data

				if (eventData.length > 0) {
					console.log('Pool address found', eventData[0])
					clearInterval(interval)
				}
			}
		}, 3000)
	} else {
		toast.error('Starknet not connect')
	}
}

const hexToDecimal = (hex: any) => parseInt(hex, 16)

export const getNextPrice = async (PoolAddress: any) => {
	await initStarknet()

	let price: number = 0

	const data = await rpcProvider.callContract({
		contractAddress: PoolAddress,
		entrypoint: 'getNextPrice',
		calldata: []
	})

	price = hexToDecimal(data.result.splice(0, 1))

	return price
}

export const getMultiplePrices = async (poolAddress: string, numberOfTokens: number): Promise<string[]> => {
	await initStarknet()

	const data = await rpcProvider.callContract({
		contractAddress: poolAddress,
		entrypoint: 'getTokenPrices',
		calldata: [numberOfTokens]
	})

	data.result.splice(0, 1)

	return data.result
}

export const buyPoolAssets = async (poolAddress: string, nfts: { collectionAddress: string; tokenId: string }[]): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	console.log('buy', nfts)

	const buyNftCalldata: string[] = []

	nfts.forEach((nft: { collectionAddress: string; tokenId: string }) => {
		buyNftCalldata.push(nft.collectionAddress)
		buyNftCalldata.push(nft.tokenId)
		buyNftCalldata.push('0')
	})

	const tokenPrices = await getMultiplePrices(poolAddress, nfts.length)
	const totalPrice = tokenPrices
		.map((priceHex) => Web3.utils.hexToNumber(priceHex))
		.reduce((curr: number, acc: number) => {
			return curr + acc
		}, 0)

	console.log(tokenPrices, totalPrice)

	const res = await starknet.account.execute([
		{
			contractAddress: ETHAddress,
			entrypoint: 'approve',
			calldata: [poolAddress, totalPrice, '0']
		},
		{
			contractAddress: poolAddress,
			entrypoint: 'buyNfts',
			calldata: [nfts.length, ...buyNftCalldata]
		}
	])

	console.log('bought', res)

	return res
}

export const setPoolParams = async (poolAddress: string, startPrice: string, delta: string): Promise<string> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	const { transaction_hash } = await starknet.account.execute({
		contractAddress: poolAddress,
		entrypoint: 'setPoolParams',
		calldata: [startPrice, '0', delta]
	})

	return transaction_hash
}

export const sellPoolAssets = async (poolAddress: string, nfts: { collectionAddress: string; tokenId: string }[]): Promise<any> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	const approvals: any[] = []
	const sellNftCalldata: string[] = []

	nfts.forEach((nft) => {
		approvals.push({
			contractAddress: nft.collectionAddress,
			entrypoint: 'approve',
			calldata: [poolAddress, nft.tokenId, '0']
		})
		sellNftCalldata.push(nft.collectionAddress)
		sellNftCalldata.push(nft.tokenId)
		sellNftCalldata.push('0')
	})

	console.log('sell nft calldata', sellNftCalldata)

	const res = await starknet.account.execute([
		...approvals,
		{
			contractAddress: poolAddress,
			entrypoint: 'sellNfts',
			calldata: [nfts.length, ...sellNftCalldata]
		}
	])

	return res
}

export const getBalance = async (poolAddress: string): Promise<number> => {
	await initStarknet()

	if (!starknet) {
		throw Error('starknet wallet not connected')
	}

	if (starknet.isConnected === false) {
		throw Error('starknet wallet not connected')
	}

	const data = await rpcProvider.callContract({
		contractAddress: poolAddress,
		entrypoint: 'getEthBalance',
		calldata: []
	})

	if (data.result.length > 1) {
		return Web3.utils.hexToNumber(data.result[0])
	}

	return 0
}

export const fetchCollectionsWithMetadata = async (collections: string[]): Promise<TableCollection[]> => {
	let addresses = []
	let tableCollections: TableCollection[] = []

	if (collections) {
		for (let i = 0; i < collections.length; i += 2) {
			addresses.push({ collectionAddress: collections[i], poolAddress: collections[i + 1] })
		}
	}

	addresses.map(async (address) => {
		const nfts = await getNFTsOfCollection(address.poolAddress, address.collectionAddress)

		const name = await getNameFromCollection(address.collectionAddress)

		const collectionAddr = address.collectionAddress
		const poolAddr = address.poolAddress

		let nftsMetadata: any = []
		if (nfts.length == 0) {
			nftsMetadata = []
		} else {
			nfts.splice(0, 1)
			nfts.forEach(async (tokenId, index) => {
				let tokenArray: any = []
				if (index % 2 === 0) {
					tokenArray.push(nfts[index], nfts[index + 1])
					const nftMetadata = await getMetaData(address.collectionAddress, tokenArray)
					nftsMetadata.push({tokenArray, nftMetadata})
				}
			});
		}

		const nextPrice = await getNextPrice(address.poolAddress)
		const volume = nfts.length * nextPrice
		const poolPrice = await getPoolConfig(address.poolAddress)

		const bestOffer = poolPrice.price
		const poolDelta = poolPrice.delta

		tableCollections.push({
			collectionAddr,
			poolAddr,
			name,
			nftsMetadata,
			volume,
			bestOffer,
			poolDelta,
			nextPrice
		})
	})

	return tableCollections
}
