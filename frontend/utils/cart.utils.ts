import { CollectionCardType } from '../pages/collections/index'

export const getTotalItems = (items: CollectionCardType[]) => items.reduce((ack: number, item) => ack + item.amount, 0)

export const isItemSelected: (cartItems: CollectionCardType[], item: any) => boolean = function (
	cartItems: CollectionCardType[],
	item: any
): boolean {
	return cartItems.find((cartItem) => cartItem.TokenId === item.id && cartItem.amount !== 0) ? true : false
}

export const toggleCartItem = (clickedItem: CollectionCardType, prev: any) => {
	const isItemInCart = prev.find((item: CollectionCardType) => item.TokenId === clickedItem.TokenId)

	if (isItemInCart) {
		return prev.map((item: CollectionCardType) => {
			console.log(item.TokenId, isItemInCart.TokenId, item.amount)
			if (item.TokenId === isItemInCart.TokenId && item.amount !== 0) {
				return { ...item, amount: 0 }
			} else if (item.TokenId !== isItemInCart.TokenId && item.amount === 0) {
				return item
			} else {
				return { ...item, amount: 1 }
			}
		})
	}
	return [...prev, { ...clickedItem, amount: 1 }]
}

export const calculateTotalAmount = (items: CollectionCardType[]) => items.reduce((ack: number, item) => ack + item.amount * item.nextPrice, 0)
