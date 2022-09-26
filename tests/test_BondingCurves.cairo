%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import split_felt, abs_value, unsigned_div_rem
from starkware.cairo.common.pow import pow

from src.bonding_curves.IBondingCurve import IBondingCurve


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
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = 30000; // 3

    let TOTAL_PRICE = Uint256(800000, 0); // 80 
    let NEXT_PRICE = Uint256(250000, 0); // 25 

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA 
    );
    let (next_price) = IBondingCurve.getNextPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_linear_curve_with_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local linear_curve_contract_address;
    %{ ids.linear_curve_contract_address = context.linear_curve_contract_address %}

    const NUMBER_TOKENS = 10; 
    let CURRENT_PRICE = Uint256(137500, 0); // 13.75
    const DELTA = 1250; // 0.125

    let TOTAL_PRICE = Uint256(1431250, 0); // 143.125
    let NEXT_PRICE = Uint256(150000, 0); // 15 

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_linear_curve_with_negative_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local linear_curve_contract_address;
    %{ ids.linear_curve_contract_address = context.linear_curve_contract_address %}

    const NUMBER_TOKENS = 2;
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = -20000; // -2

    let TOTAL_PRICE = Uint256(180000, 0); // 18
    let NEXT_PRICE = Uint256(60000, 0); // 6

    let (total_price) = IBondingCurve.getTotalPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        linear_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_exponential_curve_with_expected_output{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 5; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = 100; // 100%

    let TOTAL_PRICE = Uint256(3100000, 0); // 310 
    let NEXT_PRICE = Uint256(3200000, 0); // 320 

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_exponential_curve_with_high_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = 10000; // 10000%

    let TOTAL_PRICE = Uint256(1030300000, 0); // 103030
    let NEXT_PRICE = Uint256(103030100000, 0); // 10303010

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_exponential_curve_with_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 5; 
    let CURRENT_PRICE = Uint256(224330, 0); // 22.433
    const DELTA = 17; // 17%

    let TOTAL_PRICE = Uint256(1573540, 0); // 157.354 
    let NEXT_PRICE = Uint256(491831, 0); // 49.1831

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;

    return ();
}


@external
func test_exponential_curve_with_negative_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = -50; // -50%

    let TOTAL_PRICE = Uint256(175000, 0); // 17.5 
    let NEXT_PRICE = Uint256(12500, 0); // 1.25 

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;
    
    return ();
}


@external
func test_exponential_curve_with_negative_delta_and_decimal_numbers{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 8; 
    let CURRENT_PRICE = Uint256(12345, 0); // 1.2345
    const DELTA = -13; // -13%

    let TOTAL_PRICE = Uint256(63794, 0); // 6.3794
    let NEXT_PRICE = Uint256(4051, 0); // 0.4051

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;
    
    return ();
}


@external
func test_exponential_curve_getTotalPrice_error_for_zero_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = 0; // 0%

    %{ expect_revert(error_message="Delta cannot be zero in exponential curve (use linear curve for constant price).") %}
    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    
    return ();
}


@external
func test_exponential_curve_getNextPrice_error_for_zero_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = 0; // 0%

    %{ expect_revert(error_message="Delta cannot be zero in exponential curve (use linear curve for constant price).") %}
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    
    return ();
}


@external
func test_exponential_curve_getTotalPrice_error_for_delta_exceeding_lower_bound{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = -100; // -100%

    %{ expect_revert(error_message="Delta must be higher than -99%") %}
    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    
    return ();
}


@external
func test_exponential_curve_getNextPrice_error_for_delta_exceeding_lower_bound{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(100000, 0); // 10
    const DELTA = -100; // -100%

    %{ expect_revert(error_message="Delta must be higher than -99%") %}
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    
    return ();
}


@external
func test_exponential_curve_with_lower_bound_delta{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local exponential_curve_contract_address;
    %{ ids.exponential_curve_contract_address = context.exponential_curve_contract_address %}

    const NUMBER_TOKENS = 3; 
    let CURRENT_PRICE = Uint256(230000000, 0); // 23000
    const DELTA = -99; // -99%

    let TOTAL_PRICE = Uint256(232323000, 0); // 23232.3
    let NEXT_PRICE = Uint256(229, 0); // 0.023

    let (total_price) = IBondingCurve.getTotalPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );
    let (next_price) = IBondingCurve.getNextPrice(
        exponential_curve_contract_address, NUMBER_TOKENS, CURRENT_PRICE, DELTA
    );

    assert total_price = TOTAL_PRICE;
    assert next_price = NEXT_PRICE;
    
    return ();
}