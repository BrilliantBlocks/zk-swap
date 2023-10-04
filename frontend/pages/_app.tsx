import type { AppProps } from 'next/app'
import { theme } from '../utils/theme'
import '../styles/globals.css'
import { CacheProvider, EmotionCache } from '@emotion/react'
import { ThemeProvider, CssBaseline } from '@mui/material'
import createEmotionCache from '../utils/createEmotionCache'
import { NetworkStatusProvider } from '../hooks/useNetworks'
import { ErrorToaster } from '../components/Modals/ToasterErrorDialog'
import MainLayout from '../layouts/mainLayout'
import { useEffect, useState } from 'react'
import { Session } from 'next-auth'
import { SessionProvider } from 'next-auth/react'

type MyAppProps = AppProps & {
	Component: AppProps['Component'] & { layout?: React.Node }
	emotionCache?: EmotionCache
	pageProps: any
	session: Session
}

const clientSideEmotionCache = createEmotionCache()

function MyApp({ Component, emotionCache = clientSideEmotionCache, pageProps }: MyAppProps) {
	const PageLayout = Component.layout ?? MainLayout
	return (
		<SessionProvider session={pageProps.session} refetchInterval={0}>
			<Hydrated>
				<NetworkStatusProvider />
				<ErrorToaster />
				<CacheProvider value={emotionCache}>
					<ThemeProvider theme={theme}>
						<CssBaseline>
							<PageLayout>
								<Component {...pageProps} />
							</PageLayout>
						</CssBaseline>
					</ThemeProvider>
				</CacheProvider>
			</Hydrated>
		</SessionProvider>
	)
}

const Hydrated = ({ children }: { children?: any }) => {
	const [hydration, setHydration] = useState(false)

	useEffect(() => {
		if (typeof window !== 'undefined') {
			setHydration(true)
		}
	}, [])
	return hydration ? children : null
}

export default MyApp
