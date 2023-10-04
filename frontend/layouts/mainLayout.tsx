import AsideBar from '../components/Drawer/Drawer'
import Footer from '../components/Footer'
import NavBar from '../components/Navigation/Navbar'
import type { LayoutProps } from './pageWithLayouts'


const MainLayout: LayoutProps = ({ children }) => {
    return (
        <>
            <NavBar />
            {children}
            <Footer />
        </>
    )
}
export default MainLayout
