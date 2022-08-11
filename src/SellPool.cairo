%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_nn
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func pool_owner() -> (address: felt):
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



@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _owner: felt,
        _current_price : felt,
        _delta : felt,
        _nft_collection_len : felt,
        _nft_collection : felt*,
        _nft_list_len : felt,
        _nft_list : felt*
    ):
    alloc_locals

    with_attr error_message("Owner address cannot be zero"):
        assert_not_zero(_owner)
    end
    pool_owner.write(_owner)

    with_attr error_message("Price cannot be negative."):
        assert_nn(_current_price)
    end
    current_price.write(_current_price)

    delta.write(_delta)

    assert_len_match(_nft_collection_len, _nft_list_len)

    _add_nft_to_pool(_nft_collection_len, _nft_collection, _nft_list_len, _nft_list)

    return ()
end


# Add NFTs to pool

@external
func add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_collection_len: felt,
        _nft_collection: felt*,
        _nft_list_len: felt,
        _nft_list: felt*,
    ) -> ():
    #alloc_locals
    #assert_only_owner()
    assert_len_match(_nft_collection_len, _nft_list_len)

    _add_nft_to_pool(_nft_collection_len, _nft_collection, _nft_list_len, _nft_list)

    return ()

end


func _add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_collection_len: felt,
        _nft_collection: felt*,
        _nft_list_len: felt,
        _nft_list: felt*
    ) -> ():
    alloc_locals

    if _nft_list_len == 0:
        return ()
    end

    const start_slot_collection_array = 0
    const start_slot_element_list = 1
    let (start_id) = start_id_by_collection.read(_nft_collection[0])

    if start_id == 0:
        let (next_collection_id) = get_collection_count(start_slot_collection_array)
        collection_by_id.write(next_collection_id, _nft_collection[0])

        let (next_free_slot) = find_next_free_slot(start_slot_element_list)
        start_id_by_collection.write(_nft_collection[0], next_free_slot)
        list_element_by_id.write(next_free_slot, (_nft_list[0], 0))

        return _add_nft_to_pool(_nft_collection_len - 1, _nft_collection + 1, _nft_list_len - 1, _nft_list + 1)
    end

    let (last_collection_element) = find_last_collection_element(start_id)
    let (next_free_slot) = find_next_free_slot(start_slot_element_list)
    let (last_token_id) = get_token_id(last_collection_element)
    list_element_by_id.write(last_collection_element, (last_token_id, next_free_slot))
    list_element_by_id.write(next_free_slot, (_nft_list[0], 0))

    return _add_nft_to_pool(_nft_collection_len - 1, _nft_collection + 1, _nft_list_len - 1, _nft_list + 1)

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
        _nft_collection_len: felt,
        _nft_collection: felt*,
        _nft_list_len: felt,
        _nft_list: felt*,
    ) -> ():
    #alloc_locals
    #assert_only_owner()
    assert_len_match(_nft_collection_len, _nft_list_len)

    _remove_nft_from_pool(_nft_collection_len, _nft_collection, _nft_list_len, _nft_list)

    return ()

end


func _remove_nft_from_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_collection_len: felt,
        _nft_collection: felt*,
        _nft_list_len: felt,
        _nft_list: felt*
    ) -> ():
    
    alloc_locals

    if _nft_list_len == 0:
        return ()
    end

    let (start_id) = start_id_by_collection.read(_nft_collection[0])

    if start_id == 0:
        return ()
    end

    let (last_element, this_element) = find_element_to_be_removed(start_id, _nft_list[0])

    if last_element == 0: 
        start_id_by_collection.write(_nft_collection[0], this_element)
        list_element_by_id.write(start_id, (0, 0))
        return ()
    end

    let (this_token_id) = get_token_id(this_element)
    let (last_token_id) = get_token_id(last_element)
    let (next_collection_slot) = get_next_collection_slot(this_element)

    list_element_by_id.write(last_element, (last_token_id, next_collection_slot))
    list_element_by_id.write(this_element, (0, 0))

    return _remove_nft_from_pool(_nft_collection_len - 1, _nft_collection + 1, _nft_list_len - 1, _nft_list + 1)

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

    return ()
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
    let (_caller) = get_caller_address()
    let (_pool_owner) = pool_owner.read()
    with_attr error_message("You must be the pool owner to add NFTs to pool."):
        assert _caller = _pool_owner
    end
    return ()
end


func assert_len_match(
        _nft_collection_len: felt,
        _nft_list_len: felt,
    ) -> ():
    with_attr error_message("Collection and NFT array lengths don't match."):
        assert _nft_collection_len = _nft_list_len
    end
    
    return ()
end



# Helper functions 

@view
func get_pool_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = pool_owner.read()
    return (res)
end


@view
func get_current_price{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = current_price.read()
    return (res)
end


@view
func get_delta{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = delta.read()
    return (res)
end


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