%lang starknet

from src.pool import pool_owner, pool_type, start_price, delta, pool_balance
from src.pool import initialize_pool
from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func test_initialize_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    
    let (owner_before) = pool_owner.read()
    let (pool_type_before) = pool_type.read()
    let (start_price_before) = start_price.read()
    let (delta_before) = delta.read()
    let (pool_balance_before) = pool_balance.read(1)
    
    assert owner_before = 0
    assert pool_type_before = 0
    assert start_price_before = 0
    assert delta_before = 0
    assert pool_balance_before = 0

    initialize_pool(12345, 1, 100, 1, 10)

    let (owner_after) = pool_owner.read()
    let (pool_type_after) = pool_type.read()
    let (start_price_after) = start_price.read()
    let (delta_after) = delta.read()
    let (pool_balance_after) = pool_balance.read(1)

    assert owner_after = 12345
    assert pool_type_after = 1
    assert start_price_after = 100
    assert delta_after = 1
    assert pool_balance_after = 10
    
    return ()
end


@external
func test_owner_cannot_be_zero{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    %{ expect_revert(error_message="Owner address cannot be zero") %}
    initialize_pool(0, 1, 100, 1, 10)

    return ()
end


@external
func test_pool_type_must_be_boolean{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    %{ expect_revert(error_message="Pool type is not a boolean") %}
    initialize_pool(12345, 2, 100, 1, 10)

    return ()
end


@external
func test_pool_already_initialized{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    initialize_pool(12345, 1, 100, 1, 10)

    %{ expect_revert(error_message="Pool is already initialized") %}
    initialize_pool(12345, 0, 100, 1, 10)

    return ()
end