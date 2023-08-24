import React from 'react'
import { Typography, Box } from '@mui/material'
import CtaBtn from '../../../components/Buttons/CTAButton'
import Link from 'next/link'

const CheckoutSuccess = () => {
	return (
		<Box margin="3rem" textAlign="center">
			<Typography variant="h5" gutterBottom>
				Thank you for creating pool.
			</Typography>
			<Typography variant="subtitle1">
				Your pool in the moment is save in localstorage. You will be notified once it is available on starknet
			</Typography>
			<Box marginTop="3rem">
				<Link href="pools">
					<CtaBtn href="/pools">View Pools</CtaBtn>
				</Link>
			</Box>
		</Box>
	)
}

export default CheckoutSuccess
