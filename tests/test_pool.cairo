%lang starknet

from src.pool import pool_owner, pool_type, start_price, delta, primary_token_balance, secondary_token_balance
from src.pool import initialize_pool
from starkware.cairo.common.cairo_builtins import HashBuiltin


@external
func test_initialize_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    
    let (owner_before) = pool_owner.read()
    let (pool_type_before) = pool_type.read()
    let (start_price_before) = start_price.read()
    let (delta_before) = delta.read()
    let (primary_token_balance_before) = primary_token_balance.read()
    let (secondary_token_balance_before) = secondary_token_balance.read()
    
    assert owner_before = 0
    assert pool_type_before = 0
    assert start_price_before = 0
    assert delta_before = 0
    assert primary_token_balance_before = 0
    assert secondary_token_balance_before = 0

    initialize_pool(12345, 1, 100, 1, 10)

    let (owner_after) = pool_owner.read()
    let (pool_type_after) = pool_type.read()
    let (start_price_after) = start_price.read()
    let (delta_after) = delta.read()
    let (primary_token_balance_after) = primary_token_balance.read()
    let (secondary_token_balance_after) = secondary_token_balance.read()

    assert owner_after = 12345
    assert pool_type_after = 1
    assert start_price_after = 100
    assert delta_after = 1
    assert primary_token_balance_after = 10
    assert secondary_token_balance_after = 0
    
    return ()
end

# @external
# func test_cannot_increase_balance_with_negative_value{
#     syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
# }():
#     let (result_before) = balance.read()
#     assert result_before = 0

#     %{ expect_revert("TRANSACTION_FAILED", "Amount must be positive") %}
#     increase_balance(-42)

#     return ()
# end