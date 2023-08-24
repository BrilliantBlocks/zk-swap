import { Box } from '@mui/system'
import Footer from '../components/Footer'
import Navigation from '../components/Navigation/Navigation'
import type { LayoutProps } from './pageWithLayouts'

const CollectionsLayout: LayoutProps = ({ children }) => {
    return <>
        <Navigation />
        {children}
        <Footer />
    </>
}
export default CollectionsLayout