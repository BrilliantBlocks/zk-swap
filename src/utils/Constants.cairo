%lang starknet

from starkware.cairo.common.uint256 import Uint256

namespace LinkedList {
    const start_slot_element_list = 1;
    const start_slot_collection_array = 0;
}

namespace FunctionSelector {
    const get_total_price = 162325169460772763346477168287411866553654952715135549492070698764789678722;
    const get_next_price = 1264847828455946785227536115322282734231840299345716002372248194024334047338;
}

namespace BondingCurve {
    const lower_bound = -9999;
}