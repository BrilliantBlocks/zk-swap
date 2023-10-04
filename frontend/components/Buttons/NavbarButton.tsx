import React from "react";
import Button, { ButtonProps } from "@mui/material/Button";
import { styled } from "@mui/material/styles";

const NavbarButton = styled(Button)<ButtonProps>(({ theme }) => ({
  margin: "13px 0 0 5px",
  padding: "20px 30px",
  height: "35px",
  fontSize: 12,
  lineHeight: 1,
  backgroundColor: theme.palette.btnSecondary.main,
  color: theme.palette.primary.main,
  " &:hover": {
    backgroundColor: theme.palette.btnSecondary.dark,
  },
}))

export default NavbarButton