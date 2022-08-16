%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, split_felt
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn, unsigned_div_rem
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256

from src.IERC721 import IERC721


struct NFT:
    member address: felt
    member id: felt
end

# Events

@event
func AddTokenToPool(nft: NFT):
end

@event
func RemoveTokenFromPool(nft: NFT):
end

@event
func EditPool(_new_price: felt, _new_delta: felt):
end


# Storage

@storage_var
func pool_factory() -> (address: felt):
end 

@storage_var
func current_price() -> (res: felt):
end 

@storage_var
func delta() -> (res: felt):
end 

@storage_var
func collection_by_id(int: felt) -> (address: felt):
end

@storage_var
func start_id_by_collection(address: felt) -> (int: felt):
end

@storage_var
func list_element_by_id(int: felt) -> (res: (token_id: felt, next_id: felt)):
end

@storage_var
func eth_balance() -> (res: felt):
end



@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _factory_address: felt,
        _current_price : felt,
        _delta : felt
    ):
    alloc_locals

    with_attr error_message("Factory address cannot be zero"):
        assert_not_zero(_factory_address)
    end
    pool_factory.write(_factory_address)

    with_attr error_message("Price cannot be negative."):
        assert_nn(_current_price)
    end
    current_price.write(_current_price)

    delta.write(_delta)

    return ()
end


# Add NFTs to pool

@external
func add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    #alloc_locals
    #assert_only_owner()

    _add_nft_to_pool(_nft_array_len, _nft_array)

    return ()

end


func _add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    alloc_locals

    if _nft_array_len == 0:
        return ()
    end

    const start_slot_collection_array = 0
    const start_slot_element_list = 1
    let (start_id) = start_id_by_collection.read(_nft_array[0].address)

    if start_id == 0:
        let (next_collection_id) = get_collection_count(start_slot_collection_array)
        collection_by_id.write(next_collection_id, _nft_array[0].address)

        let (next_free_slot) = find_next_free_slot(start_slot_element_list)
        start_id_by_collection.write(_nft_array[0].address, next_free_slot)
        list_element_by_id.write(next_free_slot, (_nft_array[0].id, 0))

        # To do: Approve token for pool address in ERC721
        AddTokenToPool.emit(_nft_array[0])

        return _add_nft_to_pool(_nft_array_len - 1, _nft_array + 2)
    end

    let (last_collection_element) = find_last_collection_element(start_id)
    let (next_free_slot) = find_next_free_slot(start_slot_element_list)
    let (last_token_id) = get_token_id(last_collection_element)
    list_element_by_id.write(last_collection_element, (last_token_id, next_free_slot))
    list_element_by_id.write(next_free_slot, (_nft_array[0].id, 0))

    # To do: Approve token for pool address in ERC721
    AddTokenToPool.emit(_nft_array[0])

    return _add_nft_to_pool(_nft_array_len - 1, _nft_array + 2)

end


func find_next_free_slot{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _next_free_slot: felt
    ):

    let (s) = list_element_by_id.read(_current_id)

    if s[0] == 0:
        return (1)
    end

    let (sum) = find_next_free_slot(_current_id + 1)
    return (sum + 1)

end


func find_last_collection_element{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _last_collection_element: felt
    ):

    let (s) = list_element_by_id.read(_current_id)

    if s[1] == 0:
        return (_current_id)
    end

    return find_last_collection_element(s[1])

end


func get_collection_count{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _collection_count: felt
    ):

    let (s) = collection_by_id.read(_current_id)

    if s == 0:
        return (0)
    end

    let (sum) = get_collection_count(_current_id + 1)
    return (sum + 1)

end


# Remove NFTs from pool

@external
func remove_nft_from_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    #alloc_locals
    #assert_only_owner()

    _remove_nft_from_pool(_nft_array_len, _nft_array)

    return ()

end


func _remove_nft_from_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    
    alloc_locals

    if _nft_array_len == 0:
        return ()
    end

    let (start_id) = start_id_by_collection.read(_nft_array[0].address)

    if start_id == 0:
        return ()
    end

    let (last_element, this_element) = find_element_to_be_removed(start_id, _nft_array[0].id)

    if last_element == 0: 
        start_id_by_collection.write(_nft_array[0].address, this_element)
        list_element_by_id.write(start_id, (0, 0))

        # To do: Remove token approval for pool address in ERC721
        RemoveTokenFromPool.emit(_nft_array[0])

        return _remove_nft_from_pool(_nft_array_len - 1, _nft_array + 2)
    end

    let (this_token_id) = get_token_id(this_element)
    let (last_token_id) = get_token_id(last_element)
    let (next_collection_slot) = get_next_collection_slot(this_element)

    list_element_by_id.write(last_element, (last_token_id, next_collection_slot))
    list_element_by_id.write(this_element, (0, 0))

    # To do: Remove token approval for pool address in ERC721
    RemoveTokenFromPool.emit(_nft_array[0])

    return _remove_nft_from_pool(_nft_array_len - 1, _nft_array + 2)

end


func find_element_to_be_removed{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt,
        _token_id: felt
    ) -> (
        _last_element: felt,
        _this_element: felt
    ):
    let (_last_element) = list_element_by_id.read(_current_id)
    let (_this_element) = list_element_by_id.read(_last_element[1])

    if _last_element[0] == _token_id:
        return (0, _last_element[1])
    end

    if _this_element[0] == _token_id:
        return (_current_id, _last_element[1])
    end

    return find_element_to_be_removed(_last_element[1], _token_id)

end


# Edit pool 


@external
func edit_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _new_price: felt,
        _new_delta: felt
    ) -> ():
    #assert_only_owner()
    with_attr error_message("Price cannot be negative."):
        assert_nn(_new_price)
    end
    current_price.write(_new_price)
    delta.write(_new_delta)

    EditPool.emit(_new_price, _new_delta)

    return ()
end


# Get all pool assets

@view
func get_all_collections{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _collection_array_len: felt,
        _collection_array: felt*
    ):
    alloc_locals
    let (collection_array: felt*) = alloc()

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
        _collection_array: felt*,
        _array_index: felt,
        _current_count: felt
    ) -> (
        _collection_count: felt
    ):
    let (_collection_element) = collection_by_id.read(_array_index)
    if _collection_element == 0:
        return (_current_count)
    end

    let (_start_id) = start_id_by_collection.read(_collection_element)
    if _start_id == 0: 
        return populate_collections(_collection_array, _array_index + 1, _current_count)
    end

    _collection_array[0] = _collection_element
    return populate_collections(_collection_array + 1, _array_index + 1, _current_count + 1)

end


@view
func get_all_nfts_of_collection{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_address: felt
    ) -> (
        _nft_id_list_len: felt,
        _nft_id_list: felt*
    ):
    alloc_locals
    let (_nft_id_list: felt*) = alloc()

    with_attr error_message("Collection address cannot be negative."):
        assert_nn(_collection_address)
    end

    let (start_id) = start_id_by_collection.read(_collection_address)

    if start_id == 0:
        return (0, _nft_id_list)
    end

    tempvar list_index = 0
    tempvar current_count = 0
    let (_nft_id_list_len) = populate_nfts(_nft_id_list, list_index, start_id)

    return (_nft_id_list_len, _nft_id_list)

end


func populate_nfts{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_id_list: felt*,
        _list_index: felt,
        _current_id: felt
    ) -> (
        _nft_count: felt
    ):

    let (s) = list_element_by_id.read(_current_id)
    _nft_id_list[0] = s[0]

    if s[1] == 0:
        return (_list_index + 1)
    end

    return populate_nfts(_nft_id_list + 1, _list_index + 1, s[1])

end


# Swap NFTs

@external
func buy_nfts{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_array_len : felt,
        _nft_array : NFT*
    ) -> ():
    alloc_locals

    let (_current_price) = current_price.read()
    let (_delta) = delta.read()
    let (_total_price) = get_total_price(_nft_array_len, _current_price, _delta)

    # To do:
    # Call ERC20 contract to check if balanceOf > _total_price
    # Check if pool is approved for amount
    # -> Transfer ETH amount to pool address
    # Call ERC721 contract to transfer NFTs to caller address

    let (_old_eth_balance) = eth_balance.read()
    local _new_eth_balance = _old_eth_balance + _total_price
    eth_balance.write(_new_eth_balance)

    let (_new_price) = get_new_price(_nft_array_len, _current_price, _delta)
    current_price.write(_new_price)

    _remove_nft_from_pool(_nft_array_len, _nft_array)
    
    return ()
end


# Linear Bonding curve


func get_total_price{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _number_items: felt,
        _current_price: felt,
        _delta: felt
    ) -> (
        _total_price: felt
    ):
    alloc_locals
    local _counter = _number_items * (_number_items - 1) * _delta + 2 * _current_price * _number_items
    let (_total_price, _) = unsigned_div_rem(_counter, 2)
    
    return (_total_price)
end


func get_new_price{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _number_items: felt,
        _current_price: felt,
        _delta: felt
    ) -> (
        _new_price: felt
    ):
    alloc_locals
    local _new_price = _current_price + _delta * _number_items
    
    return (_new_price)
end


# Get pool configuration


@view
func get_pool_factory{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*, 
        range_check_ptr
    }() -> (
        _pool_factory: felt
    ):
    let (_pool_factory) = pool_factory.read()

    return (_pool_factory)
end


@view
func get_pool_config{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (
        _current_price: felt,
        _delta: felt
    ):
    let (_current_price) = current_price.read()
    let (_delta) = delta.read()
    
    return (_current_price, _delta)
end


# Further functions


func get_token_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: felt):
  
    let (x) = list_element_by_id.read(_current_id)
    return (x[0])
end


func get_next_collection_slot{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: felt):
    
    let (x) = list_element_by_id.read(_current_id)
    return (x[1])
end


func assert_only_owner{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> ():
    let (_caller_address) = get_caller_address()
    let (_contract_address) = get_contract_address()
    let (_contract_address_high, _contract_address_low) = split_felt(_contract_address)
    let (_pool_factory_address) = pool_factory.read()

    let (_pool_owner) = IERC721.ownerOf(_pool_factory_address, Uint256(_contract_address_low, _contract_address_high))
    
    with_attr error_message("You must be the pool owner to call this function."):
        assert _caller_address = _pool_owner
    end

    return ()
end


# Helper functions 


@view
func get_start_id_by_collection{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_address: felt
    ) -> (res: felt):
    
    let (res) = start_id_by_collection.read(_collection_address)
    return (res)
end


@view
func get_list_element_by_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: (felt, felt)):
    
    let (x) = list_element_by_id.read(_current_id)
    return (x)
end


@view
func get_collection_by_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _collection_id: felt
    ) -> (_collection_address: felt):
    
    let (x) = collection_by_id.read(_collection_id)
    return (x)
end


@view
func get_eth_balance{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (_eth_balance: felt):
    
    let (_eth_balance) = eth_balance.read()
    return (_eth_balance)
end