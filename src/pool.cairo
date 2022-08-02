%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

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
func pool_balance(token_type: felt) -> (balance: felt):
end 


func initialize_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _owner : felt,
    _pool_type : felt, # 0 for NFT token, 1 for ETH token
    _start_price : felt,
    _delta : felt,
    _token_amount : felt
) -> ():
    
    let (initialized) = pool_owner.read()
    with_attr error_message("Pool is already initialized"):
        assert initialized = FALSE
    end

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

    pool_balance.write(_pool_type, _token_amount)

    return ()
end