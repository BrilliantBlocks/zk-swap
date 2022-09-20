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

from src.utils.math64x61 import Math64x61
from src.bonding_curves.IBondingCurve import PriceCalculation


// To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)


@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    price_calculation: PriceCalculation
) -> (total_price: Uint256) {
    alloc_locals;

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_two = Math64x61.fromFelt(2);
    let fpm_number_tokens = Math64x61.fromFelt(price_calculation.number_tokens);
    let fpm_current_price = Math64x61.fromUint256(price_calculation.current_price);
    let fpm_delta = Math64x61.fromFelt(price_calculation.delta);

    let fpm_summand1 = Math64x61.mul(fpm_current_price, fpm_number_tokens);
    let fpm_number_tokens_red = Math64x61.sub(fpm_number_tokens, fpm_unit);
    let fpm_multiplier = Math64x61.mul(fpm_number_tokens, fpm_number_tokens_red);
    let fpm_counter = Math64x61.mul(fpm_multiplier, fpm_delta);
    let fpm_summand2 = Math64x61.div(fpm_counter, fpm_two);

    let fpm_total_price = Math64x61.add(fpm_summand1, fpm_summand2);
    let total_price_felt = Math64x61.toFelt(fpm_total_price);
    let (total_price) = convertFeltToUint(total_price_felt);

    return (total_price,);

    // total_price = current_price * number_tokens +- delta * (number_tokens - 1) * number_tokens / 2
}


@view
func getNewPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    price_calculation: PriceCalculation
) -> (new_price: Uint256) {
    alloc_locals;

    let fpm_number_tokens = Math64x61.fromFelt(price_calculation.number_tokens);
    let fpm_current_price = Math64x61.fromUint256(price_calculation.current_price);
    let fpm_delta = Math64x61.fromFelt(price_calculation.delta);

    let fpm_summand = Math64x61.mul(fpm_delta, fpm_number_tokens);
    let fpm_new_price = Math64x61.add(fpm_current_price, fpm_summand);
    let new_price_felt = Math64x61.toFelt(fpm_new_price);
    let (new_price) = convertFeltToUint(new_price_felt);

    return (new_price,);

    // new_price = current_price +- delta * number_tokens
}


func convertFeltToUint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    input: felt
) -> (output: Uint256) {
    let (output_high, output_low) = split_felt(input);
    let output = Uint256(output_low, output_high);

    return (output,);
}
