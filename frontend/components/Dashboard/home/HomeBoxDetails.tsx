import { Box } from "@mui/system";
import { Typography } from "@mui/material";
import Link from "next/link";
import { theme } from "../../../utils/theme";

const HomeBoxDetails = () => {
    return (
        <Box sx={{ marginTop: "2rem" }}>
        <Typography
          sx={{ justifyContent: "center", display: "flex", fontSize: 28, textTransform: "none" }}
        >
          All Collections
        </Typography>
        <Box
          sx={{
            justifyContent: "center",
            display: "flex",
            fontSize: 18,
            textTransform: "lowercase",
          }}
        >
          <Typography sx={{ textTransform: "none" }}>
            You can either {" "}
          </Typography>
          <Link href="/my-collection">
            <a style={{ color: theme.palette.secondary.main, fontSize: 12, marginLeft: '2px' }}>
              list your NFTs for sale 
            </a>
          </Link>
          <Typography sx={{ textTransform: "lowercase" }}>, or</Typography>

          <Link href="/create-pool">
            <a
              style={{
                color: theme.palette.secondary.main,
                fontSize: 12,
                textTransform: "none",
                marginLeft: '2px'
              }}
            >
              create a new pool to buy and sell NFT collections.
            </a>
          </Link>
        </Box>
      </Box>
    );
}
export default HomeBoxDetails;