%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import split_felt, abs_value, unsigned_div_rem
from starkware.cairo.common.pow import pow

from src.bonding_curves.IBondingCurve import IBondingCurve
from src.utils.math64x61 import Math64x61


@view
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{
        context.linear_curve_contract_address = deploy_contract("./src/bonding_curves/LinearCurve.cairo", 
            []
        ).contract_address

        context.exponential_curve_contract_address = deploy_contract("./src/bonding_curves/ExponentialCurve.cairo", 
            []
        ).contract_address
    %}

    return ();
}


@external
func test_linear_curve_with_expected_output{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local linear_curve_contract_address;
    %{ ids.linear_curve_contract_address = context.linear_curve_contract_address %}

    const NUMBER_TOKENS = 5;
    let CURRENT_PRICE = Uint256(10, 0);
    const DELTA = 3;
    let TOTAL_PRICE = Uint256(80, 0);
    let NEW_PRICE = Uint256(25, 0);

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (new_price) = IBondingCurve.getNewPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;

    return ();
}


@external
func test_linear_curve_with_negative_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local linear_curve_contract_address;
    %{ ids.linear_curve_contract_address = context.linear_curve_contract_address %}

    const NUMBER_TOKENS = 2;
    let CURRENT_PRICE = Uint256(10, 0);
    const DELTA = -2;
    let TOTAL_PRICE = Uint256(18, 0);
    let NEW_PRICE = Uint256(6, 0);

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (new_price) = IBondingCurve.getNewPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;

    return ();
}


@external
func test_exponential_curve_with_expected_output{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 5;
    let CURRENT_PRICE = Uint256(10, 0);
    const DELTA = 1;
    let TOTAL_PRICE = Uint256(310, 0);
    let NEW_PRICE = Uint256(320, 0);

    let (total_price) = IBondingCurve.getTotalPriceV2(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (new_price) = IBondingCurve.getNewPriceV2(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;

    return ();
}


@external
func test_exponential_curve_with_negative_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 10;
    let CURRENT_PRICE = Uint256(7, 0);
    let DELTA = 20; // +10%

    const base = 100;
    let delta_sum = base + DELTA;
    let (delta_sum_power) = pow(delta_sum, NUMBER_TOKENS);
    let (base_f) = pow(base, NUMBER_TOKENS);

    // Error in subtraction (?)
    let counter = delta_sum_power - base_f;
    let denominator = base_f * DELTA / base;

    // let counter_f = Math64x61.fromFelt(counter);
    // let denominator_f = Math64x61.fromFelt(denominator);
    // let fraction_f = Math64x61.div(counter_f, denominator_f);
    // let fraction_f_ = fraction_f * 10000; // 4 Nachkommastellen 
    // let fraction = Math64x61.toFelt(fraction_f_);
    
    // assert counter = 5;

    return ();
}