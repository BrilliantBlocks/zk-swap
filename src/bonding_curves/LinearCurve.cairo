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


// To do: Refactor linear bonding curve with fixed point math calculation and adjust SellPool tests
// To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)


@view
func getTotalPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (total_price: Uint256) {
    alloc_locals;

    let delta_abs = abs_value(delta);
    let (number_tokens_uint) = convertFeltToUint(number_tokens);
    let (delta_uint) = convertFeltToUint(delta_abs);

    let (a, a_overflow) = uint256_mul(current_price, number_tokens_uint);
    assertNoOverflow(a_overflow);
    let (part1, part1_overflow) = uint256_mul(a, Uint256(2, 0));
    assertNoOverflow(part1_overflow);

    let (b, b_overflow) = uint256_mul(number_tokens_uint, delta_uint);
    assertNoOverflow(b_overflow);
    let (c) = uint256_sub(number_tokens_uint, Uint256(1, 0));
    let (part2, part2_overflow) = uint256_mul(b, c);
    assertNoOverflow(part2_overflow);

    let DELTA_POSITIVE = is_nn(delta);
    if (DELTA_POSITIVE == FALSE) {
        let (counter) = uint256_sub(part1, part2);
        let (total_price, total_price_overflow) = uint256_unsigned_div_rem(counter, Uint256(2, 0));
        assertNoOverflow(total_price_overflow);
        return (total_price,);
    }

    let (counter, counter_overflow) = uint256_add(part1, part2);
    with_attr error_message("Overflow in price calculation.") {
        assert counter_overflow = FALSE;
    }
    let (total_price, total_price_overflow) = uint256_unsigned_div_rem(counter, Uint256(2, 0));
    assertNoOverflow(total_price_overflow);

    return (total_price,);

    // If Delta positive/ increasing price:
    // total_price = (2 * current_price * number_tokens + number_tokens * (number_tokens - 1) * delta)/2

    // If Delta negative/ decreasing price:
    // total_price = (2 * current_price * number_tokens - number_tokens * (number_tokens - 1) * delta)/2
}


@view
func getNewPrice{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    number_tokens: felt, current_price: Uint256, delta: felt
) -> (new_price: Uint256) {
    alloc_locals;

    let delta_abs = abs_value(delta);
    let (number_tokens_uint) = convertFeltToUint(number_tokens);
    let (delta_uint) = convertFeltToUint(delta_abs);

    let (multiplier, multiplier_overflow) = uint256_mul(number_tokens_uint, delta_uint);
    assertNoOverflow(multiplier_overflow);

    let DELTA_POSITIVE = is_nn(delta);
    if (DELTA_POSITIVE == FALSE) {
        let (new_price) = uint256_sub(current_price, multiplier);
        return (new_price,);
    }

    let (new_price, new_price_overflow) = uint256_add(current_price, multiplier);
    with_attr error_message("Overflow in price calculation.") {
        assert new_price_overflow = FALSE;
    }

    return (new_price,);

    // If Delta positive/ increasing price:
    // new_price = current_price + delta * number_tokens

    // If Delta negative/ decreasing price:
    // new_price = current_price - delta * number_tokens
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
