import { SiDiscord, SiTwitter, SiGithub } from 'react-icons/si'
import styles from './Footer.module.css'


const Footer = () => {
    return (
        <footer className={styles.footer}>
            <div className={styles.icons}>
                <a href='#' className={`${styles.icon} ${styles.twiter}`}>
                    <SiTwitter size={15} />
                </a>
                <a href='#' className={`${styles.icon} ${styles.discord}`}>
                    <SiDiscord size={15} />
                </a>
                <a href='#' className={`${styles.icon} ${styles.github}`}>
                    <SiGithub size={15} />
                </a>
            </div>
            <div className={styles.copyright} >
                ©{new Date().getFullYear()}: ZK-Swap
            </div>
        </footer>
    );
}
export default Footer;