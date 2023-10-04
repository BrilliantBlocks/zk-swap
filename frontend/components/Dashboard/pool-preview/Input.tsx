import React from 'react'
import { TextField, Typography } from '@mui/material'
import { Box } from '@mui/material'
import styles from '../../../pages/pool-preview/PoolPreview.module.css'

interface ModalInputProps {
	label: string
	label_number?: any
	value: any
	onChange?: (e: any) => void
}

const ModalInput: React.FC<ModalInputProps> = (props): React.ReactElement => {
	return (
		<Box className={styles.spacing_1}>
			<Typography className={styles.dialog_headlines}>
				{props.label} <span className={styles.bold}>{props.label_number}</span>
			</Typography>
			<TextField variant="filled" fullWidth className={styles.input} defaultValue={props.value} onChange={props.onChange} />
		</Box>
	)
}
export default ModalInput
