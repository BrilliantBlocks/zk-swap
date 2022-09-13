%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_mul, uint256_sub, uint256_add, uint256_unsigned_div_rem, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE


# To do: Refactor input parameters as PriceCalculation Struct (with Cairo v0.10.0)

@view
func getTotalPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        number_tokens: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        total_price: Uint256
    ):
    alloc_locals

    let (delta_power) = power_of_delta(delta, delta, number_tokens, 1)
    local counter = delta_power - 1
    local denominator = delta - 1
    let (fraction, fraction_overflow) = unsigned_div_rem(counter, denominator)
    with_attr error_message("Overflow in price calculation."):
        assert fraction_overflow = FALSE
    end
    let (fraction_uint) = convertFeltToUint(fraction)

    let (total_price, total_price_overflow) = uint256_mul(current_price, fraction_uint)
    assertNoOverflow(total_price_overflow)
    
    return (total_price)
end


@view
func getNewPrice{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        number_tokens: felt,
        current_price: Uint256,
        delta: felt
    ) -> (
        new_price: Uint256
    ):
    alloc_locals

    let (delta_power) = power_of_delta(delta, delta, number_tokens, 1)
    let (delta_power_uint) = convertFeltToUint(delta_power)
    let (new_price, new_price_overflow) = uint256_mul(current_price, delta_power_uint)
    assertNoOverflow(new_price_overflow)
    
    return (new_price)
end


func power_of_delta{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        initial_delta: felt,
        power_delta: felt,
        number_tokens: felt,
        current_count: felt
    ) -> (
        power: felt
    ):
    alloc_locals
    if current_count == number_tokens:
        return (power_delta)
    end

    local power_delta = power_delta * initial_delta
    
    return power_of_delta(initial_delta, power_delta, number_tokens, current_count + 1)
end


func convertFeltToUint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        input: felt
    ) -> (
        output: Uint256
    ):

    let (output_high, output_low) = split_felt(input)
    let output = Uint256(output_low, output_high)
    
    return (output)
end


func assertNoOverflow{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        input: Uint256
    ) -> ():
    alloc_locals
    local zero: Uint256 = Uint256(0, 0)
    let (no_overflow) = uint256_eq(input, zero)
    with_attr error_message("Overflow in price calculation."):
        assert no_overflow = TRUE
    end
    
    return ()
end