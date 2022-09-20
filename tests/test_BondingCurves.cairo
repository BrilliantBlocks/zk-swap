%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import split_felt, abs_value, unsigned_div_rem
from starkware.cairo.common.pow import pow

from src.bonding_curves.IBondingCurve import IBondingCurve, PriceCalculation
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

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=5, 
        current_price=Uint256(100000, 0), // 10
        delta=30000 // 3
    );

    let TOTAL_PRICE = Uint256(800000, 0); // 80 
    let NEW_PRICE = Uint256(250000, 0); // 25 

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        linear_curve_contract_address, PRICE_CALCULATION
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;

    return ();
}


@external
func test_linear_curve_with_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local linear_curve_contract_address;
    %{ ids.linear_curve_contract_address = context.linear_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=10, 
        current_price=Uint256(137500, 0), // 13.75
        delta=1250 // 0.125
    );

    let TOTAL_PRICE = Uint256(1431250, 0); // 143.125
    let NEW_PRICE = Uint256(150000, 0); // 15 

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        linear_curve_contract_address, PRICE_CALCULATION
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

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=2, 
        current_price=Uint256(100000, 0), // 10
        delta=-20000 // -2
    );

    let TOTAL_PRICE = Uint256(180000, 0); // 18
    let NEW_PRICE = Uint256(60000, 0); // 6

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        linear_curve_contract_address, PRICE_CALCULATION
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

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=5, 
        current_price=Uint256(100000, 0), // 10
        delta=100 // 100%
    );

    let TOTAL_PRICE = Uint256(3100000, 0); // 310 
    let NEW_PRICE = Uint256(3200000, 0); // 320 

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;

    return ();
}


@external
func test_exponential_curve_with_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=5, 
        current_price=Uint256(224330, 0), // 22.433
        delta=17 // 17%
    );

    let TOTAL_PRICE = Uint256(1573540, 0); // 157.354 
    let NEW_PRICE = Uint256(491831, 0); // 49.1831

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
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

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(100000, 0), // 10
        delta=-50 // -50%
    );

    let TOTAL_PRICE = Uint256(175000, 0); // 17.5 
    let NEW_PRICE = Uint256(12500, 0); // 1.25 

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;
    
    return ();
}


@external
func test_exponential_curve_with_negative_delta_and_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=8, 
        current_price=Uint256(12345, 0), // 1.2345
        delta=-13 // -13%
    );

    let TOTAL_PRICE = Uint256(63794, 0); // 6.3794
    let NEW_PRICE = Uint256(4051, 0); // 0.4051

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;
    
    return ();
}


@external
func test_exponential_curve_getTotalPrice_error_for_zero_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(100000, 0), // 10
        delta=0 // 0%
    );

    %{ expect_revert(error_message="Delta cannot be zero in exponential curve.") %}
    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    
    return ();
}


@external
func test_exponential_curve_getNewPrice_error_for_zero_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(100000, 0), // 10
        delta=0 // 0%
    );

    %{ expect_revert(error_message="Delta cannot be zero in exponential curve.") %}
    let (total_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    
    return ();
}


@external
func test_exponential_curve_getTotalPrice_error_for_delta_exceeding_lower_bound{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(100000, 0), // 10
        delta=-100 // -100%
    );

    %{ expect_revert(error_message="Delta must be higher than -99%") %}
    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    
    return ();
}


@external
func test_exponential_curve_getNewPrice_error_for_delta_exceeding_lower_bound{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(100000, 0), // 10
        delta=-100 // -100%
    );

    %{ expect_revert(error_message="Delta must be higher than -99%") %}
    let (total_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    
    return ();
}


@external
func test_exponential_curve_with_lower_bound_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    tempvar PRICE_CALCULATION: PriceCalculation = PriceCalculation(
        number_tokens=3, 
        current_price=Uint256(230000000, 0), // 23000
        delta=-99 // -99%
    );

    let TOTAL_PRICE = Uint256(232323000, 0); // 23232.3
    let NEW_PRICE = Uint256(229, 0); // 0.023

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );
    let (new_price) = IBondingCurve.getNewPrice(
        exponential_curve_contract_address, PRICE_CALCULATION
    );

    assert total_price = TOTAL_PRICE;
    assert new_price = NEW_PRICE;
    
    return ();
}