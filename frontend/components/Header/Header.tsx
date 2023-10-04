import React from 'react'
import styles from './Header.module.css'
import Image from 'next/image'
import Link from 'next/link'
import { IconButton, Input, Typography } from '@mui/material'
import { Container } from '@mui/system'
import CardIcon from '../Card/CardIcon'
import ContentCopyOutlinedIcon from '@mui/icons-material/ContentCopyOutlined'
import ExitToAppIcon from '@mui/icons-material/ExitToApp'
import { copyText } from '../../utils/helper-functions/copyText'
import toast from 'react-hot-toast'

interface HeaderProps {
    children?: React.ReactNode
    image: string
    collectionName: string
    volumeValue: number
    floorPriceValue: number
    collectionAddress: string
}

const Header: React.FC<HeaderProps> = (props): React.ReactElement => {
    return (
        <header className={styles.wrapper}>
            <Container className={`${styles.container} ${styles.content}`}>
                <div className={styles.image_container}>
                    <Image src={props.image} alt={`${props.collectionName} banner image`} width="90" height={'90'} objectFit="cover" />
                </div>
            </Container>
            <Container className={styles.collection_container}>
                <Typography variant="h2" className={styles.collection_title}>
                    {props.collectionName}
                </Typography>
            </Container>
            <Container className={styles.container}>
                <CardIcon headline="Floor Price" value={props.floorPriceValue} />
                <CardIcon headline="Volume" value={props.volumeValue} />
            </Container>
            <Container className={styles.container}>
                <Input className={styles.input} value={props.collectionAddress} />
                <IconButton
                    color="icon"
                    onClick={async () => {
                        await copyText(props.collectionAddress)
                        toast.success('Address copied successfully')
                    }}
                >
                    <ContentCopyOutlinedIcon />
                </IconButton>

                <IconButton color="icon">
                    <Link href={`https://goerli.voyager.online/contract/${props.collectionAddress}`}>
                        <a target="_blank">
                            <ExitToAppIcon />
                        </a>
                    </Link>
                </IconButton>
            </Container>
        </header>
    )
}
export default Header