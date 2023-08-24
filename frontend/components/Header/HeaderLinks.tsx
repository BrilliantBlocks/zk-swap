import styles from './Header.module.css'
import { IconButton, Input } from '@mui/material'
import { Box } from '@mui/system'
import ContentCopyOutlinedIcon from '@mui/icons-material/ContentCopyOutlined'
import ExitToAppIcon from '@mui/icons-material/ExitToApp'
import { copyText } from '../../utils/helper-functions/copyText'
import Link from 'next/link'
import toast from 'react-hot-toast'

const HeaderLinks: React.FC<{ poolAddress: string }> = (props: { poolAddress: string }): React.ReactElement => {
	return (
		<Box className={styles.container}>
			<Input className={styles.input} value={props.poolAddress} />
			<IconButton
				color="icon"
				onClick={() => {
					copyText(props.poolAddress)
					toast.success('Address copied successfully')
				}}
			>
				<ContentCopyOutlinedIcon />
			</IconButton>
			<IconButton color="icon">
				<Link href={`https://goerli.voyager.online/contract/${props.poolAddress}`}>
					<a target="_blank" style={{ marginTop: '0.4rem' }}>
						<ExitToAppIcon />
					</a>
				</Link>
			</IconButton>
		</Box>
	)
}
export default HeaderLinks
