%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, split_felt, assert_in_range, assert_nn
from starkware.cairo.common.math_cmp import is_nn
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.pow import pow

from lib.cairo_math_64x61.contracts.cairo_math_64x61.math64x61 import Math64x61

from src.utils.Converts import convertFeltToUint256
from src.utils.Constants import BondingCurve

@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    with_attr error_message("Exponential curve does not support delta = 0") {
        assert_not_zero(delta);
    }

    with_attr error_message("Delta must be in the range of [-99,99%; 1000000%]") {
        assert_in_range(delta, BondingCurve.lower_bound, BondingCurve.upper_bound);
    }

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_base = Math64x61.fromFelt(10000);
    let fpm_delta_percent = Math64x61.fromFelt(delta);
    let fpm_delta = Math64x61.div(fpm_delta_percent, fpm_base);

    let fpm_delta_sum = Math64x61.add(fpm_unit, fpm_delta);
    let fpm_delta_sum_pow = Math64x61._pow_int(fpm_delta_sum, number_tokens);
    let fpm_counter = Math64x61.sub(fpm_delta_sum_pow, fpm_unit);
    let fpm_fraction = Math64x61.div(fpm_counter, fpm_delta);

    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_total_price = Math64x61.mul(fpm_current_price, fpm_fraction);
    let total_price_felt = Math64x61.toFelt(fpm_total_price);
    let (total_price) = convertFeltToUint256(total_price_felt);

    return (total_price,);

    // total_price = current_price * (((1 +- delta)^number_tokens - 1)/(+- delta))
}

@view
func getNextPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (next_price: Uint256) {
    alloc_locals;

    with_attr error_message("Exponential curve does not support delta = 0") {
        assert_not_zero(delta);
    }

    with_attr error_message("Delta must be in the range of [-99,99%; 1000000%]") {
        assert_in_range(delta, BondingCurve.lower_bound, BondingCurve.upper_bound);
    }

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_base = Math64x61.fromFelt(10000);
    let fpm_delta_percent = Math64x61.fromFelt(delta);
    let fpm_delta = Math64x61.div(fpm_delta_percent, fpm_base);

    let fpm_delta_sum = Math64x61.add(fpm_unit, fpm_delta);
    let fpm_delta_sum_pow = Math64x61._pow_int(fpm_delta_sum, number_tokens);
    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_next_price = Math64x61.mul(fpm_current_price, fpm_delta_sum_pow);
    let next_price_felt = Math64x61.toFelt(fpm_next_price);

    with_attr error_message("The price must not be negative") {
        assert_nn(next_price_felt);
    }

    let (next_price) = convertFeltToUint256(next_price_felt);

    return (next_price,);

    // next_price = current_price * (1 +- delta)^number_tokens
}
