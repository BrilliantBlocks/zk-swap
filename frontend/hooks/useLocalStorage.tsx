import { useEffect, useState } from 'react'

type ReturnType<T> = [T | undefined, React.Dispatch<React.SetStateAction<T | undefined>>]

export const useLocalStorage = <T,>(key: string, initialValue?: T): ReturnType<T> => {
	const [state, setState] = useState<T | undefined>(() => {
		if (!initialValue) return
		try {
			const value = window?.localStorage.getItem(key)
			return value && JSON.parse(value)
		} catch (err) {
			return initialValue
		}
	})


	useEffect(() => {
		if (state) {
			try {
				localStorage.setItem(key, JSON.stringify(state))
			} catch (err) {
				console.log(err)
			}
		}
	}, [state, key])

	return [state, setState]
}
