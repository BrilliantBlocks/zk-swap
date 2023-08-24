import React from 'react'
import styles from '../../../pages/create-pool/selectAssets/SelectAssets.module.css'
import PrimaryButton from '../../PrimaryButton'
import CustomModal from '../../Modals/CustomDialog'
import { Box, Button } from '@mui/material'
import { Field } from "formik"

interface ModalNftProps {
	value?: any
	name: any
	onChange?: any
}

export const ModalNft: React.FC<ModalNftProps> = (props: any): React.ReactElement => {
	const [openReceive, setOpenReceive] = React.useState(false)

	const { label, name, value, ...rest } = props

	const handleOpenReceive = () => {
		setOpenReceive(true)
	}

	const handleCloseBtn = (event: React.SyntheticEvent<unknown>, reason?: string) => {
		if (reason !== 'backdropClick') {
			setOpenReceive(false)
		}
	}

	return (
		<>
			<PrimaryButton onClick={handleOpenReceive} backgroundColor="transparent" className={styles.btn}>
				SelectNFT
			</PrimaryButton>
			<CustomModal open={openReceive} handleClose={handleCloseBtn} title="  Select token" subtitle="Search for the Collection" onClick={handleCloseBtn}>
				<Box sx={{ display: 'flex', flexDirection: 'column', marginBlock: '1rem' }}>
					<label htmlFor={props.name} className={styles.label}>Search name, symbol, or paste address for custom token</label>
					<Box className={styles.inputBox}>
						<Field name={props.name} {...rest} className={styles.inputField} />
						<Button variant='contained' color='secondary' className={styles.formBtn} onClick={handleCloseBtn}>Add</Button>
					</Box>
				</Box>
			</CustomModal>
		</>
	)
}