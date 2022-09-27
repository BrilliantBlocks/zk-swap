%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import FALSE, TRUE

from lib.cairo_math_64x61.contracts.cairo_math_64x61.math64x61 import Math64x61

from src.utils.Converts import convertFeltToUint


@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    let fpm_unit = Math64x61.fromFelt(1);
    let fpm_two = Math64x61.fromFelt(2);
    let fpm_number_tokens = Math64x61.fromFelt(number_tokens);
    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_delta = Math64x61.fromFelt(delta);

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
func getNextPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (next_price: Uint256) {
    alloc_locals;

    let fpm_number_tokens = Math64x61.fromFelt(number_tokens);
    let fpm_current_price = Math64x61.fromUint256(current_price);
    let fpm_delta = Math64x61.fromFelt(delta);

    let fpm_summand = Math64x61.mul(fpm_delta, fpm_number_tokens);
    let fpm_next_price = Math64x61.add(fpm_current_price, fpm_summand);
    let next_price_felt = Math64x61.toFelt(fpm_next_price);
    let (next_price) = convertFeltToUint(next_price_felt);

    return (next_price,);

    // next_price = current_price +- delta * number_tokens
}

