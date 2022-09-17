%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt, abs_value, assert_not_zero, assert_le
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

from src.utils.math64x61 import Math64x61


// To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)


@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    with_attr error_message("Delta cannot be zero in exponential curve.") {
        assert_not_zero(delta);
    }

    let lower_bound = -99;
    with_attr error_message("Delta must be higher than -99%") {
        assert_le(lower_bound, delta);
    }

    // Fix point math operations

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_base = Math64x61.fromFelt(100);
    let fpm_delta_fraction = Math64x61.fromFelt(delta);
    let fpm_percent = Math64x61.mul(fpm_unit, fpm_delta_fraction);
    let fpm_delta = Math64x61.div(fpm_percent, fpm_base);
    
    let fpm_delta_sum = Math64x61.add(fpm_unit, fpm_delta);
    let fpm_delta_sum_pow = Math64x61._pow_int(fpm_delta_sum, number_tokens);
    let fpm_counter = Math64x61.sub(fpm_delta_sum_pow, fpm_unit);
    let fpm_fraction = Math64x61.div(fpm_counter, fpm_delta);

    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_total_price = Math64x61.mul(fpm_current_price, fpm_fraction);
    let fpm_total_price_dec = fpm_total_price * 10000; // 4 decimal places
    let total_price_felt = Math64x61.toFelt(fpm_total_price_dec);
    let (total_price) = convertFeltToUint(total_price_felt);

    return (total_price,);

    // total_price = current_price * (((1 +- delta)^number_tokens - 1)/(+- delta))
}


@view
func getNewPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (new_price: Uint256) {
    alloc_locals;

    with_attr error_message("Delta cannot be zero in exponential curve.") {
        assert_not_zero(delta);
    }

    let lower_bound = -99;
    with_attr error_message("Delta must be higher than -99%") {
        assert_le(lower_bound, delta);
    }

    // Fix point math operations

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_base = Math64x61.fromFelt(100);
    let fpm_delta_fraction = Math64x61.fromFelt(delta);
    let fpm_percent = Math64x61.mul(fpm_unit, fpm_delta_fraction);
    let fpm_delta = Math64x61.div(fpm_percent, fpm_base);
    
    let fpm_delta_sum = Math64x61.add(fpm_unit, fpm_delta);
    let fpm_delta_sum_pow = Math64x61._pow_int(fpm_delta_sum, number_tokens);
    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_new_price = Math64x61.mul(fpm_current_price, fpm_delta_sum_pow);
    let fpm_new_price_dec = fpm_new_price * 10000; // 4 decimal places
    let new_price_felt = Math64x61.toFelt(fpm_new_price_dec);
    let (new_price) = convertFeltToUint(new_price_felt);

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