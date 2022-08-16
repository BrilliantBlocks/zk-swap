%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem


namespace LinearCurve:

    @view
    func get_total_price{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(
            _number_items: felt,
            _current_price: felt,
            _delta: felt
        ) -> (
            _total_price: felt
        ):
        alloc_locals
        local _counter = _number_items * (_number_items - 1) * _delta + 2 * _current_price * _number_items
        let (_total_price, _) = unsigned_div_rem(_counter, 2)
        
        return (_total_price)
    end

    @view
    func get_new_price{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(
            _number_items: felt,
            _current_price: felt,
            _delta: felt
        ) -> (
            _new_price: felt
        ):
        alloc_locals
        local _new_price = _current_price + _delta * _number_items
        
        return (_new_price)
    end
    
end