import React from 'react'
import styles from './Navbar.module.css'
import { Typography, AppBar, Toolbar, Box, Button } from '@mui/material'
import Image from 'next/image'
import ArgentX from '../../services/authentication'
import logo from '../assets/images/brilliant-blocks-logo.png'
import Link from 'next/link'

const Navigation = () => {
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
		</nav>
	)
}
export default Navigation
