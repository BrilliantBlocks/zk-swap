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
from starkware.cairo.common.math import assert_not_equal, split_felt
from starkware.cairo.common.uint256 import Uint256

from src.pools.sell.ISellPool import ISellPool


struct Collection:
    member collection_address: felt
    member pool_address: felt
end

#
# Storage
#

@storage_var
func factory_owner() -> (address: felt):
end

@storage_var
func owners(pool_address: Uint256) -> (res: felt):
end

@storage_var
func pool_type_class_hash() -> (res: felt):
end

@storage_var
func pool_by_id(int: felt) -> (address: felt):
end


@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        factory_owner: felt
    ):
        factory_owner.write(factory_owner)
        return ()
end


#
# View
#

@view
func getAllCollectionsFromAllPools{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr
    }() -> (_collection_array_len: felt, _collection_array: Collection*):
    
    alloc_locals
    let (collection_array: Collection*) = alloc()

    tempvar array_index = 0
    tempvar current_count = 0

    let (collection_array_len) = populate_collections(collection_array, array_index, current_count)

    return (collection_array_len, collection_array)

end


func populate_collections{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_array: Collection*,
        _array_index: felt,
        _current_count: felt
    ) -> (
        _collection_count: felt
    ):
    let (pool_address) = pool_by_id.read(_array_index)
    if pool_address == 0:
        return (_current_count)
    end

    let (pool_collection_array_len, pool_collection_array) = ISellPool.getAllCollections(pool_address)

    let (next_count) = populate_struct(_collection_array, pool_collection_array_len, pool_collection_array, pool_address, _current_count)

    return populate_collections(_collection_array, _array_index + 1, next_count)

end


func populate_struct{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_array: Collection*,
        _pool_collection_array_len: felt,
        _pool_collection_array: felt*,
        _pool_address: felt,
        _current_count: felt
    ) -> (
        _next_count: felt
    ):
    
    if _pool_collection_array_len == 0:
        return (_current_count)
    end

    assert _collection_array[_current_count] = Collection(collection_address = _pool_collection_array[0], pool_address = _pool_address)
    
    return populate_struct(_collection_array, _pool_collection_array_len - 1, _pool_collection_array + 1, _pool_address, _current_count + 1)

end


#
# Externals
#

@external
func mint{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr
    }(_bonding_curve_class_hash : felt) -> (res: felt):

    alloc_locals
    let (local calldata: felt*) = alloc()

    let (self) = get_contract_address()
    let (pool_owner) = get_caller_address()
    let (pool_class_hash) = pool_type_class_hash.read()
    let (salt) = get_block_number()
    let calldata_len = 2

    assert calldata[0] = self
    assert calldata[1] = _bonding_curve_class_hash

    with_attr error_message("Pool deployment failed"):
        let (pool_address) = deploy(
            class_hash                = pool_class_hash,
            contract_address_salt     = salt,
            constructor_calldata_size = calldata_len,
            constructor_calldata      = calldata,
            deploy_from_zero          = FALSE
        )
    end

    let (next_free_id) = get_next_free_id(0)
    pool_by_id.write(next_free_id, pool_address)

    let (high, low) = split_felt(pool_address)
    let token_id = Uint256(low, high)

    owners.write(token_id, pool_owner)
    return (pool_address)
end


@external
func setPoolClassHash{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr
    }(_pool_type_class_hash: felt) -> ():
    assert_only_owner_or_approved()
    pool_type_class_hash.write(_pool_type_class_hash)

    return ()
end

#
# Internals
#

func get_next_free_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _next_free_id: felt
    ):
    let (s) = pool_by_id.read(_current_id)

    if s == 0:
        return (0)
    end 

    let (sum) = get_next_free_id(_current_id + 1)
    return (sum + 1)
end