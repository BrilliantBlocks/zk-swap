%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    deploy,
    get_block_number,
    get_caller_address,
    get_contract_address,
)
from starkware.cairo.common.math import assert_not_equal, split_felt, assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check
from src.pools.IPool import IPool
from tests.helper.IMintPool import Pool, Collection


// Storage


@storage_var
func _factory_owner() -> (address: felt) {
}

@storage_var
func _owners(pool_address_token: Uint256) -> (res: felt) {
}

@storage_var
func _pool_by_id(int: felt) -> (res: Pool) {
}


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    factory_owner: felt
) {
    _factory_owner.write(factory_owner);
    return ();
}


// View


@view
func getAllCollectionsFromAllPools{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    _collection_array_len: felt, _collection_array: Collection*
) {
    alloc_locals;
    let (collection_array: Collection*) = alloc();

    tempvar array_index = 0;
    tempvar current_count = 0;

    let (collection_array_len) = populate_collections(collection_array, array_index, current_count);

    return (collection_array_len, collection_array);
}


func populate_collections{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_array: Collection*, array_index: felt, current_count: felt
) -> (collection_count: felt) {
    let (pool) = _pool_by_id.read(array_index);
    if (pool.address == 0) {
        return (current_count,);
    }

    let (pool_collection_array_len, pool_collection_array) = IPool.getAllCollections(
        pool.address
    );

    let (next_count) = populate_struct(
        collection_array,
        pool_collection_array_len,
        pool_collection_array,
        pool.address,
        current_count,
    );

    return populate_collections(collection_array, array_index + 1, next_count);
}


func populate_struct{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    collection_array: Collection*,
    pool_collection_array_len: felt,
    pool_collection_array: felt*,
    pool_address: felt,
    current_count: felt,
) -> (next_count: felt) {
    if (pool_collection_array_len == 0) {
        return (current_count,);
    }

    assert collection_array[current_count] = Collection(collection_address=pool_collection_array[0], pool_address=pool_address);

    return populate_struct(
        collection_array,
        pool_collection_array_len - 1,
        pool_collection_array + 1,
        pool_address,
        current_count + 1,
    );
}


@view
func ownerOf{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    pool_address_token: Uint256
) -> (owner: felt) {
    with_attr error_message("Pool address is not a valid Uint256") {
        uint256_check(pool_address_token);
    }
    let (owner) = _owners.read(pool_address_token);
    with_attr error_message("The pool address is not existent") {
        assert_not_zero(owner);
    }
    return (owner,);
}


// Externals


@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    pool_type_class_hash: felt, bonding_curve_class_hash: felt, erc20_contract_address: felt
) -> (pool_address: felt) {
    alloc_locals;
    let (local calldata: felt*) = alloc();

    let (self) = get_contract_address();
    let (pool_owner) = get_caller_address();
    let (salt) = get_block_number();
    let calldata_len = 3;

    assert calldata[0] = self;
    assert calldata[1] = bonding_curve_class_hash;
    assert calldata[2] = erc20_contract_address;

    with_attr error_message("Pool deployment failed") {
        let (pool_address) = deploy(
            class_hash=pool_type_class_hash,
            contract_address_salt=salt,
            constructor_calldata_size=calldata_len,
            constructor_calldata=calldata,
            deploy_from_zero=FALSE,
        );
    }

    let (next_free_id) = get_next_free_id(0);
    tempvar POOL: Pool = Pool(type_class_hash=pool_type_class_hash, address=pool_address);
    _pool_by_id.write(next_free_id, POOL);

    let (high, low) = split_felt(pool_address);
    let pool_address_token = Uint256(low, high);
    _owners.write(pool_address_token, pool_owner);
    return (pool_address,);
}


// Internals


func get_next_free_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt
) -> (next_free_id: felt) {
    let (pool) = _pool_by_id.read(current_id);

    if (pool.address == 0) {
        return (0,);
    }

    let (sum) = get_next_free_id(current_id + 1);
    return (sum + 1,);
}


func assert_only_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (factory_owner) = _factory_owner.read();

    with_attr error_message("You must be the factory owner to call this function") {
        assert caller_address = factory_owner;
    }

    return ();
}


// Helper functions


@view
func getFactoryOwner{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    factory_owner: felt
) {
    let (factory_owner) = _factory_owner.read();

    return (factory_owner,);
}


@view
func getPoolTypeClassHash{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    pool_address: felt
) -> (pool_type_class_hash: felt) {
    
    let (pool_type_class_hash) = iterate_pool_list(0, pool_address);

    return (pool_type_class_hash,);
}


func iterate_pool_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_id: felt, pool_address: felt
) -> (pool_type_class_hash: felt) {
    
    let (pool) = _pool_by_id.read(current_id);

    if (pool.address == 0) {
        return (0,);
    }

    if (pool.address == pool_address) {
        return (pool.type_class_hash,);
    }

    return iterate_pool_list(current_id + 1, pool_address);

}
