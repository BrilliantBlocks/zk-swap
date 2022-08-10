%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ISellPool:
    
    func get_pool_owner() -> (res : felt):
    end

    func get_current_price() -> (res : felt):
    end

    func get_delta() -> (res : felt):
    end

    func get_start_id_by_collection(_collection_address: felt) -> (res: felt):
    end

    func get_tupel_by_id(_current_id: felt) -> (res: (felt, felt)):
    end

end