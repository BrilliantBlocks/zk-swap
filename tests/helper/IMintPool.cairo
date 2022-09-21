%lang starknet

from starkware.cairo.common.uint256 import Uint256


struct Pool {
    type_class_hash: felt,
    address: felt,
}

struct Collection {
    collection_address: felt,
    pool_address: felt,
}


@contract_interface
namespace IMintPool {

    func mint(pool_type_class_hash: felt, bonding_curve_class_hash: felt, erc20_contract_address: felt) -> (res: felt) {
    }

    func getAllCollectionsFromAllPools() -> (collection_array_len: felt, collection_array: Collection*) {
    }

    func getFactoryOwner() -> (factory_owner: felt) {
    }

    // func getPoolTypeClassHash() -> (pool_type_class_hash: felt) {
    // }
}
