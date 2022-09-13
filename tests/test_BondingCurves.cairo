%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from src.bonding_curves.IBondingCurve import IBondingCurve


@view
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    %{

        context.linear_curve_contract_address = deploy_contract("./src/bonding_curves/LinearCurve.cairo", 
            []
        ).contract_address

        context.exponential_curve_contract_address = deploy_contract("./src/bonding_curves/ExponentialCurve.cairo", 
            []
        ).contract_address

    %}

    return ()
end 


@external
func test_getTotalPrice_linear_curve{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local linear_curve_contract_address
    %{ 
        ids.linear_curve_contract_address = context.linear_curve_contract_address 
    %}

    const NUMBER_TOKENS = 5
    let CURRENT_PRICE = Uint256(10, 0)
    const DELTA = 3
    let TOTAL_PRICE = Uint256(80, 0)

    let (total_price) = IBondingCurve.getTotalPrice(linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA)

    assert total_price = TOTAL_PRICE

    return ()
end