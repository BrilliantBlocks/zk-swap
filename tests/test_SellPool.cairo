%lang starknet

from src.SellPool import pool_owner, current_price, delta
from src.SellPool import add_tupel, get_pool_owner, get_current_price, get_delta
from src.ISellPool import ISellPool
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word



const OWNER = 11111
const CURRENT_PRICE = 10
const DELTA = 1
const COLLECTION_1 = 123456789
const COLLECTION_2 = 987654321
const NFT_1_1 = 21
const NFT_1_2 = 22
const NFT_2_1 = 23

const ZERO_ID = 0
const START_ID_COLLECTION_1 = 1
const START_ID_COLLECTION_2 = 2
const NEXT_ID_COLLECTION_1 = 3



@view
func __setup__():
    %{
        context.contract_address = deploy_contract("./src/SellPool.cairo", 
            [
                ids.OWNER, ids.CURRENT_PRICE, ids.DELTA, 3, ids.COLLECTION_1, ids.COLLECTION_2, ids.COLLECTION_1, 3, ids.NFT_1_1, ids.NFT_2_1, ids.NFT_1_2
            ]
        ).contract_address
    %}
    return ()
end


@external
func test_initialization_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    let (owner) = ISellPool.get_pool_owner(contract_address)
    let (current_price) = ISellPool.get_current_price(contract_address)
    let (delta) = ISellPool.get_delta(contract_address)
    let (start_id_collection_1) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.get_start_id_by_collection(contract_address, COLLECTION_2)
    let (tuple1) = ISellPool.get_tupel_by_id(contract_address, START_ID_COLLECTION_1)
    let (tuple2) = ISellPool.get_tupel_by_id(contract_address, START_ID_COLLECTION_2)
    let (tuple3) = ISellPool.get_tupel_by_id(contract_address, NEXT_ID_COLLECTION_1)

    assert owner = OWNER
    assert current_price = CURRENT_PRICE
    assert delta = DELTA
    assert start_id_collection_1 = START_ID_COLLECTION_1
    assert start_id_collection_2 = START_ID_COLLECTION_2
    assert tuple1[0] = NFT_1_1
    assert tuple1[1] = NEXT_ID_COLLECTION_1
    assert tuple2[0] = NFT_2_1
    assert tuple2[1] = ZERO_ID
    assert tuple3[0] = NFT_1_2
    assert tuple3[1] = ZERO_ID
    
    return ()
end


