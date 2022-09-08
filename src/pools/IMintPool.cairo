%lang starknet

from starkware.cairo.common.uint256 import Uint256

from lib.diamond_contracts.contracts.facets.token.ERC721.MintPool import Collection

@contract_interface
namespace IMintPool:
    
    func setPoolClassHash(pool_type_class_hash: felt) -> ():
    end

    func mint(bonding_curve_class_hash: felt) -> (res: felt):
    end
    
    func getAllCollectionsFromAllPools() -> (collection_array_len: felt, collection_array: Collection*):
    end

end