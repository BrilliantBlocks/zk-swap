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
func nft_collection() -> (address: felt):
end 

@storage_var
func collection_by_nft(token_id: felt) -> (address: felt):
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
        _nft_collection : felt,
        _nft_list_len : felt,
        _nft_list : felt*
    ):
    
    with_attr error_message("Owner address cannot be zero"):
        assert_not_zero(_owner)
    end
    pool_owner.write(_owner)

    current_price.write(_current_price)

    delta.write(_delta)

    with_attr error_message("NFT collection cannot be zero"):
        assert_not_zero(_nft_collection)
    end
    nft_collection.write(_nft_collection)

    add_nft_to_pool(_nft_list_len, _nft_list)

    return ()
end


@external
func add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_list_len: felt,
        _nft_list: felt*,
    ) -> ():

    if _nft_list_len == 0:
        return ()
    end

    let (_nft_collection) = nft_collection.read()

    let (s) = collection_by_nft.read(_nft_list[0])
    if s == 0:
        collection_by_nft.write(_nft_list[0], _nft_collection)
        return add_nft_to_pool(_nft_list_len - 1, _nft_list + 1)
    end

    return ()

end


@external
func remove_nft_from_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(

        _nft_list_len: felt,
        _nft_list: felt*,
    ) -> ():
    
    if _nft_list_len == 0:
        return ()
    end

    let (s) = collection_by_nft.read(_nft_list[0])
    if s != 0:
        collection_by_nft.write(_nft_list[0], 0)
        return remove_nft_from_pool(_nft_list_len - 1, _nft_list + 1)
    end

    return ()

end

