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

    func get_list_element_by_id(_current_id: felt) -> (res: (felt, felt)):
    end

    func add_nft_to_pool(_nft_collection_len: felt, _nft_collection: felt*, _nft_list_len: felt,  _nft_list: felt*) -> ():
    end

    func remove_nft_from_pool(_nft_collection_len: felt, _nft_collection: felt*, _nft_list_len: felt,  _nft_list: felt*) -> ():
    end

    func edit_pool(_new_price: felt, _new_delta: felt) -> ():
    end

    func get_collection_by_id(_collection_id: felt) -> (_collection_address: felt):
    end

end