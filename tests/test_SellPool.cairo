%lang starknet

from src.SellPool import pool_owner, current_price, delta
from src.SellPool import add_tupel, get_tupel, get_tupel_id, get_pool_owner, get_current_price, get_delta
from src.ISellPool import ISellPool
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc



const OWNER = 12345
const CURRENT_PRICE = 10
const DELTA = 1

# let (ptr) = alloc()
# assert [ptr] = 20
# assert [ptr + 1] = 30


@view
func __setup__():
    %{
        context.contract_address = deploy_contract("./src/SellPool.cairo", 
            [
                ids.OWNER, ids.CURRENT_PRICE, ids.DELTA
            ]
        ).contract_address
    %}
    return ()
end


@external
func test_initialization_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    let (owner_after) = ISellPool.get_pool_owner(contract_address)
    let (current_price_after) = ISellPool.get_current_price(contract_address)
    let (delta_after) = ISellPool.get_delta(contract_address)

    assert owner_after = 12345
    assert current_price_after = 10
    assert delta_after = 1
    
    return ()
end


@external
func test_tupel{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    add_tupel(1, 22, 0)

    let (x) = get_tupel(1)
    assert x = (22,0)

    let (y) = get_tupel_id(1)
    assert y = 22
    
    return ()
end