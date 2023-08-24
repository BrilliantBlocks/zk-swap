export default {
	formId: 'checkoutForm',
	formField: {
		poolType: {
			name: 'poolType',
			label: 'Pool Type*',
			requiredErrorMsg: 'Тo continue with the steps you have to choose one of the two choices offered'
		},
		assetsDeposit: {
			name: 'assetsDeposit',
			label: 'Assets Deposit*',
			requiredErrorMsg: 'Please choose an asset to deposit'
		},
		assetsReceive: {
			name: 'assetsReceive',
			label: 'Assets Receive',
			requiredErrorMsg: 'Please choose an asset to receive'
		},
		startPrice: {
			name: 'startPrice',
			label: 'Start Price*',
			requiredErrorMsg: 'Please enter a start price',
			invalidErrorMsg: 'Entered number must be between 0 - 50'
		},
		deltaAmount: {
			name: 'deltaAmount',
			label: 'Delta*',
			requiredErrorMsg: 'Please enter delta amount',
			invalidErrorMsg: 'Entered number must be between 0 - 50'
		},
		assetAmount: {
			name: 'assetAmount',
			label: 'Asset Amount*',
			requiredErrorMsg: 'Please enter amount',
			invalidErrorMsg: 'Entered number must be between 0 - 50'
		}
	}
}
