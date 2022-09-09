%lang starknet

from starkware.cairo.common.uint256 import Uint256


struct Collection:
    member collection_address: felt
    member pool_address: felt
end


@contract_interface
namespace IMintPool:
    
    func setPoolClassHash(pool_type_class_hash: felt) -> ():
    end

    func mint(bonding_curve_class_hash: felt, erc20_contract_address: felt) -> (res: felt):
    end

    func getAllCollectionsFromAllPools() -> (collection_array_len: felt, collection_array: Collection*):
    end

    func ownerOf(pool_address: Uint256) -> (owner: felt):
    end

    func getFactoryOwner() -> (factory_owner: felt):
    end

    func getPoolTypeClassHash() -> (pool_type_class_hash: felt):
    end

end