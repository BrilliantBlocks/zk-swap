%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

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
func start_id_by_collection(address: felt) -> (int: felt):
end

@storage_var
func tupel_by_id(int: felt) -> (res: (token_id: felt, next_id: felt)):
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

    current_price.write(_current_price)

    delta.write(_delta)

    assert_len_match(_nft_collection_len, _nft_list_len)

    add_nft_to_pool(_nft_collection_len, _nft_collection, _nft_list_len, _nft_list, 1)

    return ()
end



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
        _current_id: felt
    ) -> ():
    alloc_locals

    if _nft_list_len == 0:
        return ()
    end

    let (start_id) = start_id_by_collection.read(_nft_collection[0])

    if start_id == 0:
        let (next_free_id) = find_next_free_id(_current_id)
        start_id_by_collection.write(_nft_collection[0], next_free_id)
        tupel_by_id.write(next_free_id, (_nft_list[0], 0))
        return add_nft_to_pool(_nft_collection_len - 1, _nft_collection + 1, _nft_list_len - 1, _nft_list + 1, 1)
    end

    let (last_collection_id) = find_last_collection_id(start_id)
    let (next_free_id) = find_next_free_id(_current_id)
    let (last_token_id) = get_last_token_id(last_collection_id)
    tupel_by_id.write(last_collection_id, (last_token_id, next_free_id))
    tupel_by_id.write(next_free_id, (_nft_list[0], 0))
    return add_nft_to_pool(_nft_collection_len - 1, _nft_collection + 1, _nft_list_len - 1, _nft_list + 1, 1)
    
end



func find_next_free_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _next_free_id: felt
    ):

    let (s) = tupel_by_id.read(_current_id)

    if s[0] == 0:
        return (1)
    end

    let (sum) = find_next_free_id(_current_id + 1)
    return (sum + 1)

end


func find_last_collection_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (
        _last_collection_id: felt
    ):

    let (s) = tupel_by_id.read(_current_id)

    if s[1] == 0:
        return (_current_id)
    end

    return find_last_collection_id(s[1])

end


func get_last_token_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: felt):
    
    let (x) = tupel_by_id.read(_current_id)
    return (x[0])
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
func get_tupel_by_id{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt
    ) -> (res: (felt, felt)):
    
    let (x) = tupel_by_id.read(_current_id)
    return (x)
end


@external
func add_tupel{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _current_id: felt,
        _token_id: felt,
        _next_id: felt
    ) -> ():
    
    tupel_by_id.write(_current_id, (_token_id, _next_id))

    return ()
end