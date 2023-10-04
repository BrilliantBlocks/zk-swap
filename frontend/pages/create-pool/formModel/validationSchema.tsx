import * as Yup from 'yup'
import checkoutFormModel from './checkoutFormModel'

const {
	formField: { poolType, startPrice, deltaAmount, assetAmount }
} = checkoutFormModel

export default [
	// First step in stepper validation
	Yup.object().shape({
		[poolType.name]: Yup.string().required(`${poolType.requiredErrorMsg}`)
	}),
	//   Second step, add validations if needed
	Yup.object().shape({
		// [assetsDeposit.name]: Yup.string().required(`${assetsDeposit.requiredErrorMsg}`),
		// [assetsReceive.name]: Yup.string().required(`${assetsReceive.requiredErrorMsg}`)
	}),
	//   Third step
	Yup.object().shape({
		[startPrice.name]: Yup.number().required(`${startPrice.requiredErrorMsg}`).positive().min(0).moreThan(Yup.ref('deltaAmount')),
		[deltaAmount.name]: Yup.number().required(`${deltaAmount.requiredErrorMsg}`).positive().min(0).max(100),
		[assetAmount.name]: Yup.number().required(`${assetAmount.requiredErrorMsg}`).positive().min(0).max(100)
	}),
	//   Fourth step
	Yup.object().shape({})
]
