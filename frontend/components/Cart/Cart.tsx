import CartItem from '../CartItem/CartItem'
import styles from './Cart.module.css'
import { CollectionCardType } from '../../pages/collections'
import { calculateTotalAmount } from '../../utils/cart.utils'
import { Button, Typography } from '@mui/material'
import Web3 from 'web3'
import { Box } from '@mui/system'
import Image from 'next/image'
import eth from '../assets/images/eth-logo.png'
import { buyPoolAssets, getMultiplePrices, getPoolTypeClassHash, sellPoolAssets } from '../../services/wallet.service'
import { BuyPool, SellPool } from '../../utils/manuallyDefinedValues'
import { toast } from 'react-hot-toast'

export type CartProps = {
	cartItems: CollectionCardType[]
	removeFromCart: (id: number) => void
	clearCart: () => void
	updatePrices: (cartItems: CollectionCardType[]) => void
	tradeAssets?: () => void
}

type CartItemsWithPool = { poolAddress: string; cartItems: CollectionCardType[]; poolType: string }

const Cart: React.FC<CartProps> = ({ cartItems, removeFromCart, clearCart, updatePrices, tradeAssets }) => {
	const trade = async () => {
		toast.error('Trading is currently disabled.')
		// let items: CartItemsWithPool[] = []

		// await Promise.all(
		// 	cartItems.map(async (cartItem) => {
		// 		const index = items.findIndex((item) => item.poolAddress === cartItem.poolAddress)

		// 		if (index < 0) {
		// 			const poolType = await getPoolTypeClassHash(cartItem.poolAddress)

		// 			items.push({
		// 				poolAddress: cartItem.poolAddress,
		// 				cartItems: [cartItem],
		// 				poolType
		// 			})
		// 		} else {
		// 			items[index].cartItems.push(cartItem)
		// 		}
		// 	})
		// )

		// await Promise.all(
		// 	items.map(async (item: CartItemsWithPool) => {
		// 		const nfts = item.cartItems.map((cartItem) => ({ collectionAddress: cartItem.collectionAddress, tokenId: cartItem.TokenId }))

		// 		const tokenPricesHex = await getMultiplePrices(item.poolAddress, item.cartItems.length)
		// 		const tokenPrices = tokenPricesHex.map((priceHex) => Web3.utils.hexToNumber(priceHex))

		// 		const cartItemWithNewPrices = cartItems.map((cartItem, index) => ({
		// 			...cartItem,
		// 			nextPrice: tokenPrices[index] ?? cartItem.nextPrice
		// 		}))
		// 		updatePrices(cartItemWithNewPrices)

		// 		if (item.poolType === BuyPool) {
		// 			await sellPoolAssets(item.poolAddress, nfts)
		// 			if(tradeAssets) {
		// 				tradeAssets();
		// 			}					
		// 		} else if (item.poolType === SellPool) {
		// 			await buyPoolAssets(item.poolAddress, nfts)
		// 			if(tradeAssets) {
		// 				tradeAssets();
		// 			}					
		// 		}
		// 	})
		// )
	}

	return (
		<>
			<Box className={styles.cart_container}>
				<Box className={styles.spacing}>
					{cartItems.length > 0 ? (
						<>
							<Box className={styles.cart_content}>
								<Typography className={styles.cart_title}> &gt; Buy {cartItems.length} NFTs</Typography>
								<Button className={styles.btn_clear} onClick={() => clearCart()}>
									Clear
								</Button>
							</Box>
							<Box className={styles.cart_info_wrapper}>
								<Typography variant="body2" className={styles.cart_text_color}>
									Buy Total:
								</Typography>
								<Box className={styles.card_info_content}>
									<Image src={eth} width="29" height="30" />
									<Typography variant="body2" className={styles.cart_text_color}>
										{calculateTotalAmount(cartItems).toFixed(2)}
									</Typography>
								</Box>
							</Box>
						</>
					) : null}
					{cartItems.length === 0 ? (
						<Typography variant="body2" className={styles.cart_text_color}>
							No items in cart.
						</Typography>
					) : null}
					{cartItems.map((item, key: any) => (
						<>
							<Box key={key} className={styles.spacing}>
								<CartItem item={item} key={key} removeFromCart={removeFromCart} />
							</Box>
						</>
					))}
				</Box>
				<Box className={styles.cart_info_container_text}>
					<Box className={styles.card_info_container}>
						<Typography variant="body2" className={styles.cart_text_color}>
							Net Cost:
						</Typography>
						<Box className={styles.card_info_content}>
							<Image src={eth} width="29" height="30" />
							<Typography variant="body2" className={styles.cart_text_color}>
								{calculateTotalAmount(cartItems).toFixed(2)}
							</Typography>
						</Box>
					</Box>
					<Button className={styles.btn} onClick={trade}>
						{' '}
						{'>'} Trade
					</Button>
				</Box>
			</Box>
		</>
	)
}
export default Cart
