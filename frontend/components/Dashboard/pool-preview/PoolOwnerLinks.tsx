import React from 'react'
import { Box, Input, IconButton } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'
import ContentCopyOutlinedIcon from '@mui/icons-material/ContentCopyOutlined'
import ExitToAppIcon from '@mui/icons-material/ExitToApp'
import { copyText } from '../../../utils/helper-functions/copyText'
import Link from 'next/link'
import toast from 'react-hot-toast'

interface OwnerProps {
	owner: any
}

const PoolOwnerLinks: React.FC<OwnerProps> = (props: any): React.ReactElement => {
	const owner = props.owner
	return (
		<>
			<Box className={styles.input_address_container}>
				<Input className={styles.input_address} value={owner} />
				<Box>
					<IconButton
						color="icon"
						onClick={async () => {
							await copyText(owner)
							toast.success('Address copied successfully')
						}}
					>
						<ContentCopyOutlinedIcon />
					</IconButton>
					<IconButton color="icon">
						<Link href={`https://goerli.voyager.online/contract/${owner}`}>
							<a target="_blank" style={{ marginTop: '0.4rem' }}>
								<ExitToAppIcon />
							</a>
						</Link>
					</IconButton>
				</Box>
			</Box>
		</>
	)
}

export default PoolOwnerLinks
