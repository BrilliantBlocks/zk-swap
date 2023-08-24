import * as React from 'react'
import { useState } from 'react'
import styles from './Drawer.module.css'
import Cart, { CartProps } from '../Cart/Cart'
import { Badge, Drawer, Box } from '@mui/material'
import { AddShoppingCart } from '@mui/icons-material'
import ArrowBackIosIcon from '@mui/icons-material/ArrowBackIos'
import { getTotalItems } from '../../utils/cart.utils'
import { CollectionCardType } from '../../pages/collections'

const drawerWidth = '30vw'

const AsideBar: React.FC<CartProps> = ({ cartItems, removeFromCart, clearCart, updatePrices, tradeAssets }) => {
	const [cartOpen, setCartOpen] = useState(false)

	return (
		<>
			<Drawer
				anchor="right"
				open={cartOpen}
				onClose={() => setCartOpen(false)}
				sx={{
					width: drawerWidth,
					flexShrink: 0,
					'& .MuiDrawer-paper': {
						width: drawerWidth
					}
				}}
			>
				<Box className={`${styles.cart_container} ${styles.pointer}`} onClick={() => setCartOpen(false)}>
					<Box className={styles.mt}>
						<Badge badgeContent={getTotalItems(cartItems)} color="error">
							<AddShoppingCart color="secondary" />
						</Badge>
					</Box>
					<Box className={`${styles.cart_container} ${styles.center}`}>
						<ArrowBackIosIcon color="secondary" />
					</Box>
				</Box>
				<Cart cartItems={cartItems} removeFromCart={removeFromCart} clearCart={clearCart} updatePrices={updatePrices} tradeAssets={tradeAssets} />
			</Drawer>
			<Box className={`${styles.cart_container} ${styles.top} ${styles.pointer}`} onClick={() => setCartOpen(true)}>
				<Box className={styles.mt}>
					<Badge badgeContent={getTotalItems(cartItems)} color="error">
						<AddShoppingCart color="secondary" />
					</Badge>
				</Box>
				<Box className={`${styles.cart_container} ${styles.center}`}>
					<ArrowBackIosIcon color="secondary" />
				</Box>
			</Box>
		</>
	)
}

export default AsideBar
