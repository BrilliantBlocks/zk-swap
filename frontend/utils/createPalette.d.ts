import * as createPalette from "@material-ui/core/styles/createPalette"

declare module "@mui/material/styles" {
    interface Palette {
        neutral: Palette["primary"]
        badgeMainnet: Palette["primary"]
        badgeTestinet: Palette["primary"]
        badgeDraft: Palette["primary"]
        pending: Palette["primary"]
        btnSecondary: Palette["primary"]
        menuBtn: Palette["primary"]
        icon: Palette["primary"]
        modal: Palette["primary"]
    }
    interface PaletteOptions {
        neutral?: PaletteOptions["primary"]
        badgeMainnet: PaletteOptions["primary"]
        badgeTestinet: PaletteOptions["primary"]
        badgeDraft: PaletteOptions["primary"]
        pending: PaletteOptions["primary"]
        btnSecondary: PaletteOptions["primary"]
        menuBtn: PaletteOptions["primary"]
        icon: PaletteOptions["primary"]
        modal: PaletteOptions["primary"]
    }
}
// Update the Button's color prop options
declare module "@mui/material/Button" {
    interface ButtonPropsColorOverrides {
        btnSecondary: {
            main: true
            hover: true
        }
        menuBtn: {
            main: true
            dark: true
            contrastText?: true
        }
    }
}
declare module "@mui/material/IconButton" {
    interface IconButtonPropsColorOverrides {
        icon: true
        menuBtn: true
    }
}

export default function createPalette(palette: PaletteOptions)