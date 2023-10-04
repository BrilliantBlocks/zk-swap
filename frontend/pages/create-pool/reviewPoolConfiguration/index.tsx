import React from 'react'
import { useFormikContext } from 'formik'
import { Typography, Grid } from '@mui/material'
import SelectPoolType from '../selectPoolType'
import SelectAssets from '../selectAssets'

const PoolPreview = () => {
	const { values: formValues } = useFormikContext()
	return (
		<>
			<React.Fragment>
				<Typography variant="h6" gutterBottom>
					Order summary
				</Typography>
				<Grid container spacing={2}>
					<SelectPoolType formValues={formValues} />
					<SelectAssets formValues={formValues} />
				</Grid>
			</React.Fragment>
			<Typography>Pool preview</Typography>
		</>
	)
}

export default PoolPreview
