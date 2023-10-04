import React from 'react'
import { at } from 'lodash'
import { useField } from 'formik'
import { Typography } from '@mui/material'
import { Box, Radio, RadioGroup, FormControl, FormControlLabel, FormHelperText } from '@mui/material'
import styles from '../selectPoolType/PoolType.module.css'

const PoolTypeField = (props: any) => {
	const { label, value, imgSrc, ...rest } = props
	const [field, meta, helper] = useField(props)
	const { setValue } = helper
	const className = props

	function errorMessage() {
		const [touched, error] = at(meta, 'touched', 'error')
		if (touched && error) {
			return <FormHelperText sx={{ color: 'red', textTransform: 'none' }}>{error} !</FormHelperText>
		}
	}

	function onChange(e: React.ChangeEvent<HTMLInputElement>) {
		setValue((e.target as HTMLInputElement).value)
	}

	return (
		<FormControl {...rest} variant="standard">
			<RadioGroup {...field} onChange={onChange}>
				<FormControlLabel
					value={value}
					control={<Radio className={styles.radio} />}
					label={
						<Box className={className}>
							<Typography fontWeight="800">{value}</Typography>
							<Box component="img" src={imgSrc} sx={{ height: '100px', padding: '1rem 0' }} />
							<Typography textTransform="none" fontSize="12px">
								{label}
							</Typography>
						</Box>
					}
				/>
			</RadioGroup>
			{errorMessage()}
		</FormControl>
	)
}

export default PoolTypeField
