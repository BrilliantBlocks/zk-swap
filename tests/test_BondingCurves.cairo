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

    const NUMBER_TOKENS = 3;
    let CURRENT_PRICE = Uint256(10, 0);
    let DELTA = 10; // [-99%; X]
    let PERCENT = 100;

    let base = Math64x61.fromFelt(1);
    let delta_fraction = Math64x61.fromFelt(DELTA);
    let percent = Math64x61.fromFelt(PERCENT);
    let inter_step = Math64x61.mul(base, delta_fraction);
    let delta = Math64x61.div(inter_step, percent);
    
    let delta_sum = Math64x61.add(base, delta);
    let number_tokens = Math64x61.fromFelt(NUMBER_TOKENS);
    let delta_sum_pow = Math64x61.pow(delta_sum, number_tokens);
    let counter = Math64x61.sub(delta_sum_pow, base);
    let denominator = delta;
    let fraction = Math64x61.div(counter, denominator);
    let current_price = Math64x61.fromUint256(CURRENT_PRICE);
    let total_price = Math64x61.mul(current_price, fraction);
    let total_price_ = total_price * 10000; // 4 Nachkommastellen 
    let TOTAL_PRICE = Math64x61.toFelt(total_price_);

    // assert TOTAL_PRICE = 331;

    return ();
}