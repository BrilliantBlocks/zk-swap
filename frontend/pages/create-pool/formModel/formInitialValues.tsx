import checkoutFormModel from './checkoutFormModel'

const {
	formField: { poolType, assetsDeposit, assetsReceive, startPrice, deltaAmount, assetAmount }
} = checkoutFormModel

// Initial values of the stepper validator
export default {
	[poolType.name]: '',
	[assetsDeposit.name]: '',
	[assetsReceive.name]: '',
	[startPrice.name]: '0',
	[deltaAmount.name]: '0',
	[assetAmount.name]: ''
}
