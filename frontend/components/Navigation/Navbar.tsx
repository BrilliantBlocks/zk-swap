import React, { useEffect, useState } from 'react'
import styles from './Navbar.module.css'
import { Typography, AppBar, Toolbar, Box, Button } from '@mui/material'
import Image from 'next/image'
import AsideBar from '../Drawer/Drawer'
import ArgentX from '../../services/authentication'
import Link from 'next/link'

export type CollectionCardType = {
	TokenId: string
	name: string
	hash: string
	value: number
	image: string
	amount: number
	collectionAddress: string
	poolAddress: string
	nextPrice: number
}

const NavBar = () => {
	const INITIAL_STATE: CollectionCardType[] = []
	const [cartItems, setCartItems] = useState(INITIAL_STATE)

	useEffect(() => {
		const cartData = JSON.parse(localStorage.getItem('cart') as string)
		if (cartData) {
			setCartItems(cartData)
		}
	}, [])

	useEffect(() => {
		if (cartItems !== INITIAL_STATE) {
			localStorage.setItem('cart', JSON.stringify(cartItems))
		}
	}, [cartItems])

	const handleRemoveFromCart = (id: number) => {
		setCartItems((prev) =>
			prev.reduce((ack, item) => {
				if (item.TokenId === `${id}`) {
					if (item.amount === 1) return ack
					return [...ack, { ...item, amount: 0 }]
				} else {
					return [...ack, item]
				}
			}, [] as CollectionCardType[])
		)
	}

	const handleClearCart = () => {
		setCartItems([])
	}

	const updatePrices = (cartItems: CollectionCardType[]) => {
		setCartItems(cartItems)
	}

	return (
		<nav style={{ display: 'flex' }}>
			<AppBar position="static" sx={{ zIndex: (theme) => theme.zIndex.drawer + 0 }} className={styles.nav}>
				<Toolbar className={styles.nav_container}>
					<Box className={styles.nav_content}>
						<Box className={styles.logo_container}>
							<Link href="/">
								<Box className={styles.logo_container}>
									<Typography variant="h1" component="h4" className={styles.logo}>
										ZK-Swap
									</Typography>
								</Box>
							</Link>
							<Link href="/">
								<Button variant="contained" className={`${styles.btn_light} ${styles.button} ${styles.yellow}`}>
									Collections
								</Button>
							</Link>
						</Box>
					</Box>
					<Box className={styles.btn_container}>
						<Link href="my-collection">
							<Button variant="contained" className={`${styles.btn_light} ${styles.button} ${styles.yellow}`}>
								Your NFTs
							</Button>
						</Link>
						<Link href="pools">
							<Button variant="contained" className={`${styles.btn_light} ${styles.button} ${styles.yellow}`}>
								Your Pools
							</Button>
						</Link>
						<ArgentX />
					</Box>
				</Toolbar>
			</AppBar>
			<AsideBar
				cartItems={cartItems.filter((cartItem: any) => cartItem.amount !== 0) as any[]}
				removeFromCart={handleRemoveFromCart}
				clearCart={handleClearCart}
				updatePrices={updatePrices}
			/>
		</nav>
	)
}
export default NavBar
