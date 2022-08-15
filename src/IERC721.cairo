%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC721:
        func name() -> (res : felt):
        end

        func symbol() -> (res : felt):
        end

        func balanceOf(_owner : felt) -> (res : Uint256):
        end

        func ownerOf(_tokenId : Uint256) -> (res : felt):
        end

        func getApproved(_tokenId : Uint256) -> (res : felt):
        end

        func isApprovedForAll(_owner : felt, _operator : felt) -> (res : felt):
        end

        func tokenURI(_tokenId : Uint256) -> (tokenURI_len : felt, tokenURI : felt*):
        end

        func approve(_to : felt, _tokenId : Uint256) -> ():
        end

        func setApprovalForAll(_operator : felt, _approved : felt) -> ():
        end

        func transferFrom(_from : felt, _to : felt, _tokenId : Uint256) -> ():
        end

        func safeTransferFrom(_from : felt, _to : felt, _tokenId : Uint256, data_len : felt, data : felt*) -> ():
        end

        func setTokenURI(tokenURI_len : felt, tokenURI : felt*) -> ():
        end
end