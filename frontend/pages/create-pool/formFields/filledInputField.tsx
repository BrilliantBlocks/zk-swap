import React from 'react'
import styles from '../configurePoolParameters/Configure.module.css'
import { FilledInput, FormControl, InputAdornment, Typography } from '@mui/material'
import { FormHelperText } from '@mui/material'
import { at } from 'lodash'
import { useField } from 'formik'

export const FilledInputField = (props: any) => {
	const { text, id, value, ...rest } = props
	const [field, meta, helper] = useField(props)
	const { setValue } = helper
	const [touched, error] = at(meta, 'touched', 'error')
	const isError = touched && error && true

	function _renderHelperText() {
		if (isError) {
			return <FormHelperText>{error}</FormHelperText>
		}
	}

	function onChange(e: React.ChangeEvent<HTMLInputElement>) {
		setValue((e.target as HTMLInputElement).value)
	}

	return (
		<>
			<FormControl variant="filled" className={styles.spacing_r} error={isError} onChange={onChange}>
				<FilledInput
					type="text"
					id={props.id}
					{...field}
					{...rest}
					className={styles.input_filled}
					endAdornment={
						<InputAdornment position="end" className={styles.adornmentInput}>
							<Typography className={styles.bold}>{text}</Typography>
						</InputAdornment>
					}
				/>
				<FormHelperText id="filled-input-helper-text">{_renderHelperText()}</FormHelperText>
			</FormControl>
		</>
	)
}
