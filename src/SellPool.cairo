%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

@storage_var
func pool_owner() -> (address: felt):
end 

@storage_var
func start_price() -> (res: felt):
end 

@storage_var
func delta() -> (res: felt):
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
        _start_price : felt,
        _delta : felt,
        _nft_collection : felt,
        _nft_list_len : felt,
        _nft_list : felt*
    ):
    
    with_attr error_message("Owner address cannot be zero"):
        assert_not_zero(_owner)
    end
    pool_owner.write(_owner)

    start_price.write(_start_price)

    delta.write(_delta)

    with_attr error_message("NFT collection cannot be zero"):
        assert_not_zero(_nft_collection)
    end

    add_nft_to_pool(_nft_collection, _nft_list_len, _nft_list)

    return ()
end


# @external
# func add_nft_to_pool{
#         syscall_ptr: felt*,
#         pedersen_ptr: HashBuiltin*,
#         range_check_ptr
#     }(
#         _nft_collection: felt,
#         _nft_list_len: felt,
#         _nft_list: felt*,
#         _current_count: felt
#     ) -> ():
    
#     if _nft_list_len == 0:
#         return ()
#     end

#     let (s) = nft_list.read(_current_count)
#     if s == _nft_list[0]:
#         return add_nft_to_pool(_nft_list_len - 1, _nft_list + 1, _current_count + 1)
#     end
#     if s == 0:
#         nft_list.write(_current_count, _nft_list[0])
#         return add_nft_to_pool(_nft_list_len - 1, _nft_list + 1, _current_count + 1)
#     end
#     return add_nft_to_pool(_nft_list_len, _nft_list, _current_count + 1)
# end


@external
func add_nft_to_pool{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _nft_collection: felt,
        _nft_list_len: felt,
        _nft_list: felt*,
    ) -> ():
    
    if _nft_list_len == 0:
        return ()
    end

    let (s) = collection_by_nft.read(_nft_list[0])
    if s == 0:
        collection_by_nft.write(_nft_list[0], _nft_collection)
        return add_nft_to_pool(_nft_collection, _nft_list_len - 1, _nft_list + 1)
    end

    return ()

end

