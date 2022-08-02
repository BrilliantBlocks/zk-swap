%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

@storage_var
func pool_owner() -> (address: felt):
end 

@storage_var
func pool_type() -> (id: felt):
end 

@storage_var
func start_price() -> (res: felt):
end 

@storage_var
func delta() -> (res: felt):
end 

@storage_var
func primary_token_balance() -> (res: felt):
end 

@storage_var
func secondary_token_balance() -> (res: felt):
end 


func initialize_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _owner : felt,
    _pool_type : felt,
    _start_price : felt,
    _delta : felt,
    _token_amount : felt
) -> ():
    
    with_attr error_message("Owner address cannot be zero"):
        assert_not_zero(_owner)
    end
    pool_owner.write(_owner)
    
    with_attr error_message("Pool type is not a boolean"):
        assert _pool_type * (1 - _pool_type) = 0
    end
    pool_type.write(_pool_type)

    start_price.write(_start_price)

    delta.write(_delta)

    primary_token_balance.write(_token_amount)

    return ()
end