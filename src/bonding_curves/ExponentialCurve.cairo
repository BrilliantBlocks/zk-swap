%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt, abs_value
from starkware.cairo.common.math_cmp import is_nn
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_mul,
    uint256_sub,
    uint256_add,
    uint256_unsigned_div_rem,
    uint256_eq,
)
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.pow import pow


// To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)


@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    let DELTA_POSITIVE = is_nn(delta);
    if (DELTA_POSITIVE == FALSE) {
        let delta_abs = abs_value(delta);
        let (delta_inverse, delta_inverse_overflow) = unsigned_div_rem(1, delta_abs);
        with_attr error_message("Overflow in price calculation.") {
            assert delta_inverse_overflow = FALSE;
        }
        let (delta_inverse_power) = pow(delta_inverse, number_tokens);

        local counter = delta_inverse_power - 1;
        local denominator = delta_inverse - 1;
        let (fraction, fraction_overflow) = unsigned_div_rem(counter, denominator);
        with_attr error_message("Overflow in price calculation.") {
            assert fraction_overflow = FALSE;
        }
        let (fraction_uint) = convertFeltToUint(fraction);

        let (total_price, total_price_overflow) = uint256_mul(current_price, fraction_uint);
        assertNoOverflow(total_price_overflow);

        return (total_price,);
    }

    let (delta_power) = pow(delta, number_tokens);
    local counter = delta_power - 1;
    local denominator = delta - 1;
    let (fraction, fraction_overflow) = unsigned_div_rem(counter, denominator);
    with_attr error_message("Overflow in price calculation.") {
        assert fraction_overflow = FALSE;
    }
    let (fraction_uint) = convertFeltToUint(fraction);

    let (total_price, total_price_overflow) = uint256_mul(current_price, fraction_uint);
    assertNoOverflow(total_price_overflow);

    return (total_price,);

    // If Delta positive/ increasing price:
    // total_price = current_price * ((delta^number_tokens - 1)/(delta - 1))

    // If Delta negative/ decreasing price:
    // total_price = current_price * (((1/delta)^number_tokens - 1)/((1/delta) - 1))
}


@view
func getNewPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (new_price: Uint256) {
    alloc_locals;

    let DELTA_POSITIVE = is_nn(delta);
    if (DELTA_POSITIVE == FALSE) {
        let delta_abs = abs_value(delta);
        let (delta_power) = pow(delta_abs, number_tokens);
        let (delta_power_uint) = convertFeltToUint(delta_power);
        let (total_price, total_price_overflow) = uint256_unsigned_div_rem(
            current_price, delta_power_uint
        );
        assertNoOverflow(total_price_overflow);
        return (total_price,);
    }

    let (delta_power) = pow(delta, number_tokens);
    let (delta_power_uint) = convertFeltToUint(delta_power);
    let (new_price, new_price_overflow) = uint256_mul(current_price, delta_power_uint);
    assertNoOverflow(new_price_overflow);

    return (new_price,);

    // If Delta positive/ increasing price:
    // new_price = current_price * delta^number_tokens

    // If Delta negative/ decreasing price:
    // new_price = current_price/delta^number_tokens
}


// New version of price calculation with Delta as percentage number


@view
func getTotalPriceV2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    local delta_sum = 1 + delta;
    let (delta_sum_power) = pow(delta_sum, number_tokens);
    local counter = delta_sum_power - 1;
    local denominator = delta_sum - 1;
    let (fraction, fraction_overflow) = unsigned_div_rem(counter, denominator);
    with_attr error_message("Overflow in price calculation.") {
        assert fraction_overflow = FALSE;
    }
    let (fraction_uint) = convertFeltToUint(fraction);

    let (total_price, total_price_overflow) = uint256_mul(current_price, fraction_uint);
    assertNoOverflow(total_price_overflow);

    return (total_price,);

    // total_price = current_price * (((1 +- delta)^number_tokens - 1)/((1 +- delta) - 1))
}


@view
func getNewPriceV2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (new_price: Uint256) {
    alloc_locals;

    local delta_sum = 1 + delta;
    let (delta_sum_power) = pow(delta_sum, number_tokens);
    let (delta_sum_power_uint) = convertFeltToUint(delta_sum_power);
    let (new_price, new_price_overflow) = uint256_mul(current_price, delta_sum_power_uint);
    assertNoOverflow(new_price_overflow);

    return (new_price,);

    // new_price = current_price * (1 +- delta)^number_tokens
}


func convertFeltToUint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    input: felt
) -> (output: Uint256) {
    let (output_high, output_low) = split_felt(input);
    let output = Uint256(output_low, output_high);

    return (output,);
}


func assertNoOverflow{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    input: Uint256
) -> () {
    alloc_locals;
    local zero: Uint256 = Uint256(0, 0);
    let (no_overflow) = uint256_eq(input, zero);
    with_attr error_message("Overflow in price calculation.") {
        assert no_overflow = TRUE;
    }

    return ();
}
