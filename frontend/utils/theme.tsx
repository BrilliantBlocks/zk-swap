import { createTheme } from "@mui/material/styles";


//COLORS
//Dark Blue Colors
const primaryColor = '#08042F'
const primaryFontColor = '#fefefe'

//LightGrey Color
const secondaryColorMain = '#fac079'
const secondaryColorDark = '#F5B700'

//Background Color -Light Greyblue
const lightBgColor = '#E8F5FD'
const paperBgColor = 'rgb(8,4,47)'

//Neutral Greys
const neutralMainBgColor = '#FF0000'
const neutralMainFontColor = '#fff'

//Mainnent Colors=>Green
const badgeMainnetMainColor = '#4CAB44'
const badgeMainnetLightColor = '#B1D0AE'
const badgeMainnetDarkColor = '#008000'

//Testinet Colors=>Green
const badgeTestinetMainColor = '#BEFF03'

//Pending Badge Colors=>Green
const badgePendingMainColor = '#B1D0AE'

//Draft Badge Colors=>Green
const badgeDraftMainColor = '#9CC2D9'

//Dashboard ButtonGroup Color=> Light Grey
const btnSecondaryColor = '#E8F5FD'
const btnSecondaryColorDark = '#C7DAFA'

//Color of Text
const headingsColor = '#61666A'
const bodyTextColorLight = '#fefefe'

//Color of Icons-Light Grey
const iconLight = '#cfcece'

//Color of Headlines(Modals) - White
const modalText = '#fff'


export const theme = createTheme({
    palette: {
        primary: {
            main: primaryColor,
            contrastText: primaryFontColor
        },
        secondary: {
            main: secondaryColorMain,
            dark: secondaryColorDark
        },
        background: {
            default: primaryColor,
            paper: paperBgColor
        },
        badgeMainnet: {
            main: badgeMainnetMainColor,
            light: badgeMainnetLightColor,
            dark: badgeMainnetDarkColor
        },
        neutral: {
            main: neutralMainBgColor,
            contrastText: neutralMainFontColor
        },
        badgeTestinet: {
            main: badgeTestinetMainColor
        },
        badgeDraft: {
            main: badgeDraftMainColor
        },
        pending: {
            main: badgePendingMainColor
        },
        btnSecondary: {
            main: btnSecondaryColor,
            dark: btnSecondaryColorDark
        },
        menuBtn: {
            main: modalText,
            dark: modalText,
            contrastText: 'black'
        },
        icon: {
            main: iconLight
        },
        modal: {
            main: modalText
        },

        tonalOffset: 0.2
    },
    typography: {
        fontFamily: 'Inter',
        fontWeightLight: 300,
        fontWeightRegular: 400,
        fontWeightMedium: 500,
        fontWeightBold: 600,
        h1: {
            color: bodyTextColorLight
        },
        body1: { textTransform: 'uppercase' },
        subtitle1: { color: headingsColor },
        body2: {
            color: bodyTextColorLight,
            fontSize: '14px!important',
            fontWeight: '700 !important'
        }
    },
    shape: {
        borderRadius: 30
    },

    components: {
        MuiButton: {
            styleOverrides: {
                root: {
                    fontSize: '24',
                    fontWeight: 'bold'
                },
                fullWidth: {
                    maxWidth: '100px'
                },
                disableElevation: true
            }
        },
        MuiButtonBase: {
            defaultProps: {
                disableRipple: true
            }
        },

        MuiPaper: {
            styleOverrides: {
                root: {
                    backgroundColor: primaryColor,
                    width: '60%'
                }
            }
        },
        MuiTypography: {
            styleOverrides: {
                root: {
                    fontWeight: 500,
                    fontSize: '12px'
                },
                body1: {
                    color: '#fefefe!important',
                    fontWeight: 300
                }
            }
        },
        MuiCardHeader: {
            styleOverrides: {
                title: {
                    textTransform: 'capitalize'
                },
                subheader: {
                    color: iconLight,
                    fontWeight: '300 !important',
                    fontSize: '0.6rem !important',
                    marginTop: '2px'
                }
            }
        },
        MuiFormControlLabel: {
            styleOverrides: {
                label: {
                    color: '#6f8498 !important',
                    fontWeight: 800
                }
            }
        },
        MuiInputBase: {
            styleOverrides: {
                root: {
                    'MuiInputAdornment-root': {
                        endAdornment: {
                            color: '#fefefe!important'
                        }
                    }
                },
                input: {
                    fontWeight: '300 !important',
                    paddingBottom: '1.2rem !important'
                }
            }
        },
        MuiOutlinedInput: {
            styleOverrides: {
                input: {
                    color: '#fff !important',
                    fontWeight: '300 !important'
                }
            }
        }
    }
})