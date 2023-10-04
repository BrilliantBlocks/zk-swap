import * as React from 'react'
import Box from '@mui/material/Box'
import Stepper from '@mui/material/Stepper'
import Step from '@mui/material/Step'
import { Divider, Typography } from '@mui/material'
import { useState } from 'react'
import Button from '@mui/material/Button'
import CircularProgress from '@mui/material/CircularProgress'
import styles from './CreatePool.module.css'
import { StepIconProps } from '@mui/material/StepIcon'
import { Formik, Form } from 'formik'
import CheckoutSuccess from './checkoutSuccess/checkoutSuccess'
import formInitialValues from './formModel/formInitialValues'
import validationSchema from './formModel/validationSchema'
import checkoutFormModel from './formModel/checkoutFormModel'
import SelectPoolType, { PoolType } from './selectPoolType'
import SelectAssets from './selectAssets'
import PoolParameters from './configurePoolParameters'
import { CustomizedStepLabel } from '../../components/Stepper/StepLabel'
import { ColorlibStepIconRoot } from '../../components/Stepper/StepIconRoot'
import PrimaryButton from '../../components/PrimaryButton'
import { storePool } from '../../utils/helper-functions/storePool'
import { uuid } from 'uuidv4'
import { walletAddress } from '../../services/wallet.service'
import { ETHAddress } from '../../utils/manuallyDefinedValues'

const steps = ['Selecting Pool Type', 'Selecting Assets', 'Configuring Pool Parameters']

const { formId, formField } = checkoutFormModel

function renderStepContent(step: any, poolType: PoolType, onPoolTypeUpdate: (poolType: PoolType) => void) {
	switch (step) {
		case 0:
			return <SelectPoolType formField={formField} onPoolTypeUpdate={onPoolTypeUpdate} />
		case 1:
			return <SelectAssets formField={formField} poolType={poolType} />
		case 2:
			return <PoolParameters formField={formField} />
		default:
			return <div>Not Found</div>
	}
}

function ColorlibStepIcon(props: StepIconProps) {
	const { active, completed, className } = props

	const icons: { [index: string]: any } = {
		1: 1,
		2: 2,
		3: 3,
		4: 4
	}
	return (
		<ColorlibStepIconRoot ownerState={{ completed, active }} className={className}>
			{icons[String(props.icon)]}
		</ColorlibStepIconRoot>
	)
}

const CreatePool = () => {
	const [activeStep, setActiveStep] = useState(0)
	const currentValidationSchema = validationSchema[activeStep]
	const isLastStep = activeStep === steps.length - 1
	const [poolType, setPoolType] = useState<PoolType>('Buy NFTs with tokens')

	async function submitForm(values: any, actions: any) {
		const [ownerAddress, error] = await walletAddress()
		actions.setSubmitting(false)
		setActiveStep(activeStep + 1)
		storePool({
			id: uuid(),
			owner: ownerAddress,
			transactionHash: '',
			paramsTransactionHash: '',
			collectionTransactionHash: '',
			poolAddress: '',
			collectionAddress: values.assetsDeposit,
			startPrice: values.startPrice,
			deltaAmount: values.deltaAmount,
			poolType: values.poolType,
			ethAddress: ETHAddress
		})
	}

	function handleSubmit(values: any, actions: any) {
		if (isLastStep) {
			submitForm(values, actions)
		} else {
			console.log(values.assetsDeposit)
			console.log(values.startPrice),
			console.log(values.deltaAmount),
			console.log(values.poolType),
			console.log(ETHAddress),
			setActiveStep(activeStep + 1)
			actions.setTouched({})
			actions.setSubmitting(false)
		}
	}

	function handleBack() {
		setActiveStep(activeStep - 1)
	}

	function onPoolTypeUpdate(poolType: PoolType) {
		setPoolType(poolType)
	}

	return (
		<React.Fragment>
			<Box className={styles.stepperBox}>
				<Box>
					<Typography component="h1" variant="h4" className={styles.headline}>
						Create Pool
					</Typography>
					<Typography className={styles.subheading}>Provide liquidity for NFT trading.</Typography>
				</Box>
				<Divider component="div" role="presentation" className={styles.divider} />
				<Stepper activeStep={activeStep} className={styles.stepper}>
					{steps.map((label) => (
						<Step key={label}>
							<CustomizedStepLabel StepIconComponent={ColorlibStepIcon}>{label}</CustomizedStepLabel>
						</Step>
					))}
				</Stepper>
				<React.Fragment>
					{activeStep === steps.length ? (
						<CheckoutSuccess />
					) : (
						<Formik initialValues={formInitialValues} validationSchema={currentValidationSchema} enableReinitialize onSubmit={handleSubmit}>
							{({ isSubmitting }) => (
								<Form id={formId}>
									{renderStepContent(activeStep, poolType, onPoolTypeUpdate)}
									<Box display="flex" justifyContent="space-between">
										{activeStep !== 0 && (
											<PrimaryButton onClick={handleBack} backgroundColor="transparent" className={styles.btn}>
												Back
											</PrimaryButton>
										)}
										<Box>
											<Button disabled={isSubmitting} type="submit" className={styles.btn}>
												{isLastStep ? 'Create Pool' : 'Next Step'}
											</Button>
											{isSubmitting && <CircularProgress size={24} />}
										</Box>
									</Box>
								</Form>
							)}
						</Formik>
					)}
				</React.Fragment>
			</Box>
		</React.Fragment>
	)
}
export default CreatePool
