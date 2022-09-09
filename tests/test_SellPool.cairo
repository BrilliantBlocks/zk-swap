%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_contract_address

from src.pools.sell.ISellPool import ISellPool
from src.pools.IMintPool import IMintPool, Collection
from src.pools.sell.SellPool import NFT, PoolParams

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721Metadata import IERC721Metadata
from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20


const POOL_FACTORY = 123456789
const CURRENT_PRICE_LOW = 10
const CURRENT_PRICE_HIGH = 0
const DELTA = 1

const C1_NAME = 'COLLECTION 1'
const C2_NAME = 'COLLECTION 2'
const C3_NAME = 'COLLECTION 3'
const ERC20_NAME = 'ERC20 Test Contract'
const C1_SYMBOL = 'C1'
const C2_SYMBOL = 'C2'
const C3_SYMBOL = 'C3'
const ERC20_SYMBOL = 'ERC20'
const DECIMALS = 18
const INITIAL_SUPPLY_LOW = 50
const INITIAL_SUPPLY_HIGH = 0 
const ERC721_TOKEN_OWNER = 321
const ERC721_TOKEN_BUYER = 789
const POOL_FACTORY_OWNER = 123456789


@view
func __setup__{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals
    let (ERC_CONTRACT_OWNER) = get_contract_address()

    %{

        context.c1_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.c2_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C2_NAME, ids.C2_SYMBOL, ids.ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.c3_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C3_NAME, ids.C3_SYMBOL, ids.ERC_CONTRACT_OWNER
            ]
        ).contract_address

        context.erc20_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20Mintable.cairo", 
            [ 
                ids.ERC20_NAME, ids.ERC20_SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.ERC721_TOKEN_BUYER, ids.ERC_CONTRACT_OWNER
            ]
        ).contract_address


        context.pool_factory_contract_address = deploy_contract("./src/pools/MintPool.cairo", 
            [
                ids.POOL_FACTORY_OWNER
            ]
        ).contract_address

        context.sell_pool_class_hash = declare("./src/pools/sell/SellPool.cairo").class_hash

        context.linear_curve_class_hash = declare("./src/bonding-curves/linear/LinearCurve.cairo").class_hash

        context.sell_pool_contract_address = deploy_contract("./src/pools/sell/SellPool.cairo", 
            [
                ids.POOL_FACTORY, context.linear_curve_class_hash, context.erc20_contract_address, ids.CURRENT_PRICE_LOW, ids.CURRENT_PRICE_HIGH, ids.DELTA
            ]
        ).contract_address

    %}

    local c1_contract_address
    local c2_contract_address
    local c3_contract_address
    local erc20_contract_address
    %{ 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    
    ISellPool.mint(c1_contract_address, ERC721_TOKEN_OWNER, NFT_1_1)
    ISellPool.mint(c1_contract_address, ERC721_TOKEN_OWNER, NFT_1_2)
    ISellPool.mint(c2_contract_address, ERC721_TOKEN_OWNER, NFT_2_1)
    ISellPool.mint(c2_contract_address, ERC721_TOKEN_OWNER, NFT_2_2)
    ISellPool.mint(c3_contract_address, ERC721_TOKEN_OWNER, NFT_3_1)
    ISellPool.mint(erc20_contract_address, ERC721_TOKEN_OWNER, Uint256(30, 0))

    return ()
end 


@external
func test_initialization_pool_factory{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local pool_factory_contract_address
    %{ 
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
    %}

    let (collection_array_len: felt, collection_array: Collection*) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address)
    
    assert collection_array_len = 0

    return ()
end


# @external
# func test_mint_sell_pool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

#     alloc_locals 

#     local pool_factory_contract_address
#     local sell_pool_class_hash
#     local linear_curve_class_hash
#     %{ 
#         ids.pool_factory_contract_address = context.pool_factory_contract_address 
#         ids.sell_pool_class_hash = context.sell_pool_class_hash
#         ids.linear_curve_class_hash = context.linear_curve_class_hash 
#     %}

#     # %{ expect_revert(error_message="Pool deployment failed") %}
#     # let (pool_address) = IMintPool.mint(pool_factory_contract_address, linear_curve_class_hash)


#     let (pool_type_class_hash_before) = IMintPool.getPoolTypeClassHash(pool_factory_contract_address)
#     let (factory_owner) = IMintPool.getFactoryOwner(pool_factory_contract_address)
#     assert pool_type_class_hash_before = 0
#     assert factory_owner = POOL_FACTORY_OWNER

#     IMintPool.setPoolClassHash(pool_factory_contract_address, sell_pool_class_hash)

#     let (pool_type_class_hash_after) = IMintPool.getPoolTypeClassHash(pool_factory_contract_address)
#     assert pool_type_class_hash_after = sell_pool_class_hash

#     let (pool_address) = IMintPool.mint(pool_factory_contract_address, linear_curve_class_hash)

#     assert pool_address = 123

#     return ()
# end


@external
func test_initialization_ERC_contracts{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local c1_contract_address
    local c2_contract_address
    local c3_contract_address
    local erc20_contract_address
    %{ 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)

    let (c1_balance) = IERC721.balanceOf(c1_contract_address, ERC721_TOKEN_OWNER)
    let (c2_balance) = IERC721.balanceOf(c2_contract_address, ERC721_TOKEN_OWNER)
    let (c3_balance) = IERC721.balanceOf(c3_contract_address, ERC721_TOKEN_OWNER)
    let (erc20_balance_token_buyer) = IERC20.balanceOf(erc20_contract_address, ERC721_TOKEN_BUYER)
    let (erc20_balance_token_owner) = IERC20.balanceOf(erc20_contract_address, ERC721_TOKEN_OWNER)
    let (c1_token_owner) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (c2_token_owner) = IERC721.ownerOf(c2_contract_address, NFT_2_1)
    let (c3_token_owner) = IERC721.ownerOf(c3_contract_address, NFT_3_1)
    let (erc20_total_supply) = IERC20.totalSupply(erc20_contract_address)
    
    assert c1_balance = Uint256(2, 0)
    assert c2_balance = Uint256(2, 0)
    assert c3_balance = Uint256(1, 0)
    assert erc20_balance_token_buyer = Uint256(50, 0)
    assert erc20_balance_token_owner = Uint256(30, 0)
    assert erc20_total_supply = Uint256(80, 0)
    assert c1_token_owner = ERC721_TOKEN_OWNER
    assert c2_token_owner = ERC721_TOKEN_OWNER
    assert c3_token_owner = ERC721_TOKEN_OWNER
    
    return ()
end


@external
func test_getPoolConfig_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    tempvar POOL_PARAMS : PoolParams = PoolParams(price=Uint256(10, 0), delta=1)

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (pool_params: PoolParams) = ISellPool.getPoolConfig(sell_pool_contract_address)
    
    assert pool_factory = POOL_FACTORY
    assert pool_params.price = POOL_PARAMS.price
    assert pool_params.delta = POOL_PARAMS.delta
    
    return ()
end


@external
func test_addNftToPool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local c3_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    tempvar POOL_PARAMS : PoolParams = PoolParams(price=Uint256(10, 0), delta=1)
    let COLLECTION_1 = c1_contract_address
    let COLLECTION_2 = c2_contract_address
    let COLLECTION_3 = c3_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    let ZERO_UINT = Uint256(0, 0)
    const ZERO_FELT = 0
    const COLLECTION_ARRAY_LEN = 2
    const NFT_COLLECTION_1_ARRAY_LEN = 2
    const NFT_COLLECTION_2_ARRAY_LEN = 1

    let (NFT_ARRAY_1 : NFT*) = alloc()
    assert NFT_ARRAY_1[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_1[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_1[2] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1)
    %{ 
        stop_prank_callable_1() 
        stop_prank_callable_2() 
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 3, NFT_ARRAY_1)
    %{ 
        stop_prank_callable_3() 
    %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let (collection_address_1) = ISellPool.getCollectionById(sell_pool_contract_address, 0)
    let (collection_address_2) = ISellPool.getCollectionById(sell_pool_contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (pool_balance_c2) = IERC721.balanceOf(c2_contract_address, sell_pool_contract_address)
    let (new_owner_c1) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (new_owner_c2) = IERC721.ownerOf(c2_contract_address, NFT_2_1)

    assert pool_factory = POOL_FACTORY
    assert pool_params.price = POOL_PARAMS.price
    assert pool_params.delta = POOL_PARAMS.delta
    assert start_id_collection_1 = 1
    assert start_id_collection_2 = 2
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = 3
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = ZERO_FELT
    assert list_element_3[0] = NFT_1_2
    assert list_element_3[1] = ZERO_FELT
    assert collection_address_1 = COLLECTION_1
    assert collection_address_2 = COLLECTION_2
    assert collection_array_len = COLLECTION_ARRAY_LEN
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert nft_collection_1_id_list_len = NFT_COLLECTION_1_ARRAY_LEN
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_1_id_list[1] = NFT_1_2
    assert nft_collection_2_id_list_len = NFT_COLLECTION_2_ARRAY_LEN
    assert nft_collection_2_id_list[0] = NFT_2_1
    assert nft_collection_3_id_list_len = ZERO_FELT
    assert pool_balance_c1 = Uint256(2, 0)
    assert pool_balance_c2 = Uint256(1, 0)
    assert new_owner_c1 = sell_pool_contract_address
    assert new_owner_c2 = sell_pool_contract_address

    let (NFT_ARRAY_2 : NFT*) = alloc()
    assert NFT_ARRAY_2[0] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_2[1] = NFT(address = COLLECTION_3, id = NFT_3_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2)
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1)
    %{ 
        stop_prank_callable_1()  
        stop_prank_callable_2()
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY_2)
    %{ 
        stop_prank_callable_3() 
    %}

    let (start_id_collection_3) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_3)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let list_element_5 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 5)
    let (pool_balance_c3) = IERC721.balanceOf(c3_contract_address, sell_pool_contract_address)
    let (new_owner_c3) = IERC721.ownerOf(c3_contract_address, NFT_3_1)

    assert start_id_collection_3 = 5
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = 4
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
    assert pool_balance_c3 = Uint256(1, 0)
    assert new_owner_c3 = sell_pool_contract_address
    
    return ()
end


@external
func test_removeNftFromPool{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local c3_contract_address

    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
    %}

    tempvar POOL_PARAMS : PoolParams = PoolParams(price=Uint256(10, 0), delta=1)
    let COLLECTION_1 = c1_contract_address
    let COLLECTION_2 = c2_contract_address
    let COLLECTION_3 = c3_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    let ZERO_UINT = Uint256(0, 0)
    const ZERO_FELT = 0

    let (NFT_ARRAY_ADD : NFT*) = alloc()

    assert NFT_ARRAY_ADD[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY_ADD[1] = NFT(address = COLLECTION_2, id = NFT_2_1)
    assert NFT_ARRAY_ADD[2] = NFT(address = COLLECTION_1, id = NFT_1_2)
    assert NFT_ARRAY_ADD[3] = NFT(address = COLLECTION_2, id = NFT_2_2)
    assert NFT_ARRAY_ADD[4] = NFT(address = COLLECTION_3, id = NFT_3_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2)
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1)
    %{ 
        stop_prank_callable_1() 
        stop_prank_callable_2() 
        stop_prank_callable_3() 
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY_ADD)
    %{ 
        stop_prank_callable_4() 
    %}

    let (pool_factory) = ISellPool.getPoolFactory(sell_pool_contract_address)
    let (pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let (start_id_collection_3) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_3)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let list_element_5 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 5)
    let (collection_address_1) = ISellPool.getCollectionById(sell_pool_contract_address, 0)
    let (collection_address_2) = ISellPool.getCollectionById(sell_pool_contract_address, 1)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)

    assert pool_factory = POOL_FACTORY
    assert pool_params.price = POOL_PARAMS.price
    assert pool_params.delta = POOL_PARAMS.delta
    assert start_id_collection_1 = 1
    assert start_id_collection_2 = 2
    assert start_id_collection_3 = 5
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = 3
    assert list_element_2[0] = NFT_2_1
    assert list_element_2[1] = 4
    assert list_element_3[0] = NFT_1_2
    assert list_element_3[1] = ZERO_FELT
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
    assert collection_address_1 = COLLECTION_1
    assert collection_address_2 = COLLECTION_2
    assert collection_array_len = 3
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert collection_array[2] = COLLECTION_3
    assert nft_collection_1_id_list_len = 2
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_1_id_list[1] = NFT_1_2
    assert nft_collection_2_id_list_len = 2
    assert nft_collection_2_id_list[0] = NFT_2_1
    assert nft_collection_2_id_list[1] = NFT_2_2
    assert nft_collection_3_id_list_len = 1
    assert nft_collection_3_id_list[0] = NFT_3_1
    assert pool_balance_c1 = Uint256(2, 0)

    let (NFT_ARRAY_REMOVE : NFT*) = alloc()
    assert NFT_ARRAY_REMOVE[0] = NFT(address = COLLECTION_1, id = NFT_1_2)
    assert NFT_ARRAY_REMOVE[1] = NFT(address = COLLECTION_2, id = NFT_2_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    ISellPool.removeNftFromPool(sell_pool_contract_address, 2, NFT_ARRAY_REMOVE)
    %{ stop_prank_callable() %}

    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_start_id_collection_2) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_2)
    let list_element_1 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 1)
    let list_element_2 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 2)
    let list_element_3 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 3)
    let list_element_4 : (Uint256, felt) = ISellPool.getListElementById(sell_pool_contract_address, 4)
    let (collection_array_len, collection_array) = ISellPool.getAllCollections(sell_pool_contract_address)
    let (nft_collection_1_id_list_len: felt, nft_collection_1_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_1)
    let (nft_collection_2_id_list_len: felt, nft_collection_2_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_2)
    let (nft_collection_3_id_list_len: felt, nft_collection_3_id_list: Uint256*) = ISellPool.getAllNftsOfCollection(sell_pool_contract_address, COLLECTION_3)
    let (pool_balance_c1) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (pool_balance_c2) = IERC721.balanceOf(c2_contract_address, sell_pool_contract_address)
    let (new_owner_c1) = IERC721.ownerOf(c1_contract_address, NFT_1_2)
    let (new_owner_c2) = IERC721.ownerOf(c2_contract_address, NFT_2_1)

    assert new_start_id_collection_1 = 1
    assert new_start_id_collection_2 = 4
    assert list_element_1[0] = NFT_1_1
    assert list_element_1[1] = ZERO_FELT
    assert list_element_2[0] = ZERO_UINT
    assert list_element_2[1] = ZERO_FELT
    assert list_element_3[0] = ZERO_UINT
    assert list_element_3[1] = ZERO_FELT
    assert list_element_4[0] = NFT_2_2
    assert list_element_4[1] = ZERO_FELT
    assert list_element_5[0] = NFT_3_1
    assert list_element_5[1] = ZERO_FELT
    assert collection_array_len = 3
    assert collection_array[0] = COLLECTION_1
    assert collection_array[1] = COLLECTION_2
    assert collection_array[2] = COLLECTION_3
    assert nft_collection_1_id_list_len = 1
    assert nft_collection_1_id_list[0] = NFT_1_1
    assert nft_collection_2_id_list_len = 1
    assert nft_collection_2_id_list[0] = NFT_2_2
    assert nft_collection_3_id_list_len = 1
    assert nft_collection_3_id_list[0] = NFT_3_1
    assert pool_balance_c1 = Uint256(1, 0)
    assert pool_balance_c2 = Uint256(1, 0)
    assert new_owner_c1 = ERC721_TOKEN_OWNER
    assert new_owner_c2 = ERC721_TOKEN_OWNER
    
    return ()
end


@external
func test_editPool_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    tempvar POOL_PARAMS : PoolParams = PoolParams(price=Uint256(10, 0), delta=1)
    tempvar NEW_POOL_PARAMS : PoolParams = PoolParams(price=Uint256(15, 0), delta=2)

    let (old_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)

    assert old_pool_params.price = POOL_PARAMS.price
    assert old_pool_params.delta = POOL_PARAMS.delta

    ISellPool.editPool(sell_pool_contract_address, NEW_POOL_PARAMS)

    let (new_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)

    assert new_pool_params.price = NEW_POOL_PARAMS.price
    assert new_pool_params.delta = NEW_POOL_PARAMS.delta

    return ()
end


@external
func test_buyNfts{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address
    let (ERC_CONTRACT_AND_TOKEN_OWNER) = get_contract_address()
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    const ZERO_FELT = 0
    let OLD_ETH_BALANCE = Uint256(0, 0)
    let NEW_ETH_BALANCE = Uint256(21, 0)
    let OLD_PRICE = Uint256(10, 0)
    let NEW_PRICE = Uint256(12, 0)
    let ERC20_OWNER_BALANCE_BEFORE = Uint256(50, 0)
    let ERC20_OWNER_BALANCE_AFTER = Uint256(29, 0)
    let TOTAL_PRICE = Uint256(21, 0)
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY)
    %{ 
        stop_prank_callable_2() 
    %}

    let (old_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (old_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (pool_balance_before) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (owner_before) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (erc20_owner_balance_before) = IERC20.balanceOf(erc20_contract_address, ERC721_TOKEN_BUYER)
    
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = 1
    assert old_pool_params.price = OLD_PRICE
    assert pool_balance_before = Uint256(2, 0)
    assert owner_before = sell_pool_contract_address
    assert erc20_owner_balance_before = ERC20_OWNER_BALANCE_BEFORE

    %{  
        PRANK_ERC721_TOKEN_BUYER = 789
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)
    %{ 
        stop_prank_callable_2() 
    %}

    let (new_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (pool_balance_after) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (owner_after) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (erc20_owner_balance_after) = IERC20.balanceOf(erc20_contract_address, ERC721_TOKEN_BUYER)
    
    assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_FELT
    assert new_pool_params.price = NEW_PRICE
    assert pool_balance_after = Uint256(0, 0)
    assert owner_after = ERC721_TOKEN_BUYER
    assert erc20_owner_balance_after = ERC20_OWNER_BALANCE_AFTER

    return ()
end


@external
func test_buyNfts_from_different_collections{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    const ZERO_FELT = 0
    let NEW_PRICE = Uint256(14, 0)
    let TOTAL_PRICE = Uint256(46, 0)
    let ERC20_OWNER_BALANCE_AFTER = Uint256(4, 0)
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = c1_contract_address, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = c1_contract_address, id = NFT_1_2)
    assert NFT_ARRAY[2] = NFT(address = c2_contract_address, id = NFT_2_1)
    assert NFT_ARRAY[3] = NFT(address = c2_contract_address, id = NFT_2_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2)
    %{ 
        stop_prank_callable_1() 
        stop_prank_callable_2()
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 4, NFT_ARRAY)
    %{ 
        stop_prank_callable_3() 
    %}

    %{  
        PRANK_ERC721_TOKEN_BUYER = 789
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.buyNfts(sell_pool_contract_address, 4, NFT_ARRAY)
    %{ 
        stop_prank_callable_2() 
    %}

    let (new_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, c1_contract_address)
    let (new_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (pool_balance_after) = IERC721.balanceOf(c1_contract_address, sell_pool_contract_address)
    let (owner_after) = IERC721.ownerOf(c1_contract_address, NFT_1_1)
    let (erc20_owner_balance_after) = IERC20.balanceOf(erc20_contract_address, ERC721_TOKEN_BUYER)
    
    assert new_eth_balance = TOTAL_PRICE
    assert new_start_id_collection_1 = ZERO_FELT
    assert new_pool_params.price = NEW_PRICE
    assert pool_balance_after = Uint256(0, 0)
    assert owner_after = ERC721_TOKEN_BUYER
    assert erc20_owner_balance_after = ERC20_OWNER_BALANCE_AFTER

    return ()
end


@external
func test_buyNfts_with_unsufficient_eth_balance{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local c2_contract_address
    local c3_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.c3_contract_address = context.c3_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    let NFT_2_1 = Uint256(21, 0)
    let NFT_2_2 = Uint256(22, 0)
    let NFT_3_1 = Uint256(31, 0)
    let TOTAL_PRICE = Uint256(60, 0)
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = c1_contract_address, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = c1_contract_address, id = NFT_1_2)
    assert NFT_ARRAY[2] = NFT(address = c2_contract_address, id = NFT_2_1)
    assert NFT_ARRAY[3] = NFT(address = c2_contract_address, id = NFT_2_2)
    assert NFT_ARRAY[4] = NFT(address = c3_contract_address, id = NFT_3_1)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c3_contract_address)
        stop_prank_callable_4 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_1)
    IERC721.approve(c2_contract_address, sell_pool_contract_address, NFT_2_2)
    IERC721.approve(c3_contract_address, sell_pool_contract_address, NFT_3_1)
    %{ 
        stop_prank_callable_1() 
        stop_prank_callable_2()
        stop_prank_callable_3()
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 5, NFT_ARRAY)
    %{ 
        stop_prank_callable_4() 
    %}

    %{  
        PRANK_ERC721_TOKEN_BUYER = 789
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE)
    %{ 
        stop_prank_callable_1() 
    %}

    %{ expect_revert(error_message="Your ETH balance is unsufficient.") %}
    ISellPool.buyNfts(sell_pool_contract_address, 5, NFT_ARRAY)

    %{ 
        stop_prank_callable_2() 
    %}

    return ()
end


@external
func test_buyNfts_with_toggling_pool_pause{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    const ZERO_FELT = 0
    let OLD_ETH_BALANCE = Uint256(0, 0)
    let NEW_ETH_BALANCE = Uint256(21, 0)
    let OLD_PRICE = Uint256(10, 0)
    let NEW_PRICE = Uint256(12, 0)
    let TOTAL_PRICE = Uint256(21, 0)
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY)
    ISellPool.togglePause(sell_pool_contract_address)

    let (old_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (old_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    
    assert old_eth_balance = OLD_ETH_BALANCE
    assert start_id_collection_1 = 1
    assert old_pool_params.price = OLD_PRICE
    assert is_paused = TRUE

    ISellPool.togglePause(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    assert is_paused = FALSE
    %{ 
        stop_prank_callable_2() 
    %}

    %{  
        PRANK_ERC721_TOKEN_BUYER = 789
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE)

    %{ stop_prank_callable_1() %}

    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)

    %{ stop_prank_callable_2() %}

    let (new_eth_balance) = ISellPool.getEthBalance(sell_pool_contract_address)
    let (new_start_id_collection_1) = ISellPool.getStartIdByCollection(sell_pool_contract_address, COLLECTION_1)
    let (new_pool_params) = ISellPool.getPoolConfig(sell_pool_contract_address)
    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    
    assert new_eth_balance = NEW_ETH_BALANCE
    assert new_start_id_collection_1 = ZERO_FELT
    assert new_pool_params.price = NEW_PRICE
    assert is_paused = FALSE

    return ()
end


@external
func test_cannot_buyNfts_when_pool_paused{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local c1_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let COLLECTION_1 = c1_contract_address
    let NFT_1_1 = Uint256(11, 0)
    let NFT_1_2 = Uint256(12, 0)
    const ZERO_FELT = 0
    let TOTAL_PRICE = Uint256(21, 0)
    
    let (NFT_ARRAY : NFT*) = alloc()
    assert NFT_ARRAY[0] = NFT(address = COLLECTION_1, id = NFT_1_1)
    assert NFT_ARRAY[1] = NFT(address = COLLECTION_1, id = NFT_1_2)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_1)
    IERC721.approve(c1_contract_address, sell_pool_contract_address, NFT_1_2)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.addNftToPool(sell_pool_contract_address, 2, NFT_ARRAY)
    ISellPool.togglePause(sell_pool_contract_address)
    %{ 
        stop_prank_callable_2() 
    %}

    let (is_paused) = ISellPool.isPaused(sell_pool_contract_address)
    assert is_paused = TRUE

    %{  
        PRANK_ERC721_TOKEN_BUYER = 789
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_BUYER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, TOTAL_PRICE)

    %{ stop_prank_callable_1() %}

    %{ expect_revert(error_message="Pool is currently paused.") %}
    ISellPool.buyNfts(sell_pool_contract_address, 2, NFT_ARRAY)

    %{ stop_prank_callable_2() %}

    return ()
end


@external
func test_getNextPrice_with_expected_output{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 

    local sell_pool_contract_address
    %{ ids.sell_pool_contract_address = context.sell_pool_contract_address %}

    let NEXT_PRICE = Uint256(11, 0)

    let (next_price) = ISellPool.getNextPrice(sell_pool_contract_address)

    assert next_price = NEXT_PRICE

    return ()
end


@external
func test_depositEth{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let ERC721_TOKEN_OWNER_BALANCE = Uint256(30, 0)
    let POOL_BALANCE_BEFORE = Uint256(0, 0)
    let POOL_BALANCE_AFTER = Uint256(30, 0)

    let (pool_balance_before) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_before = POOL_BALANCE_BEFORE

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    %{ 
        stop_prank_callable_1() 
    %}

    ISellPool.depositEth(sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    %{ 
        stop_prank_callable_2()
    %}

    let (pool_balance_after) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_after = POOL_BALANCE_AFTER

    return ()
end


@external
func test_depositEth_with_unsufficient_balance{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let ERC721_TOKEN_OWNER_BALANCE = Uint256(30, 0)
    let EXCEEDING_AMOUNT = Uint256(40, 0)
    let POOL_BALANCE_BEFORE = Uint256(0, 0)

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, EXCEEDING_AMOUNT)
    %{ 
        stop_prank_callable_1() 
    %}

    %{ expect_revert(error_message="Your ETH balance is unsufficient.") %}
    ISellPool.depositEth(sell_pool_contract_address, EXCEEDING_AMOUNT)
    %{ 
        stop_prank_callable_2()
    %}

    return ()
end


@external
func test_withdrawEth{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let ERC721_TOKEN_OWNER_BALANCE = Uint256(30, 0)
    let POOL_BALANCE_BEFORE = Uint256(0, 0)
    let WITHDRAWAL_BALANCE = Uint256(15, 0)
    let POOL_BALANCE_AFTER_DEPOSIT = Uint256(30, 0)
    let POOL_BALANCE_AFTER_WITHDRAWAL = Uint256(15, 0)
    let POOL_BALANCE_AFTER_WITHDRAWAL_ALL = Uint256(0, 0)

    let (pool_balance_before) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_before = POOL_BALANCE_BEFORE

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.depositEth(sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    
    let (pool_balance_after_deposit) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_after_deposit = POOL_BALANCE_AFTER_DEPOSIT

    let (pool_balance_erc20_contract) = IERC20.balanceOf(erc20_contract_address, sell_pool_contract_address)
    assert pool_balance_erc20_contract = POOL_BALANCE_AFTER_DEPOSIT

    ISellPool.withdrawEth(sell_pool_contract_address, WITHDRAWAL_BALANCE)

    let (pool_balance_after_withdrawal) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_after_withdrawal = POOL_BALANCE_AFTER_WITHDRAWAL

    ISellPool.withdrawAllEth(sell_pool_contract_address)

    let (pool_balance_after_withdrawal_all) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_after_withdrawal_all = POOL_BALANCE_AFTER_WITHDRAWAL_ALL

    %{ expect_revert(error_message="Pool has no ETH to withdraw.") %}
    ISellPool.withdrawAllEth(sell_pool_contract_address)

    %{ 
        stop_prank_callable_2()
    %}

    return ()
end


@external
func test_withdrawEth_with_unsufficient_pool_balance{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():

    alloc_locals 
    local sell_pool_contract_address
    local erc20_contract_address
    %{ 
        ids.sell_pool_contract_address = context.sell_pool_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let ERC721_TOKEN_OWNER_BALANCE = Uint256(30, 0)
    let POOL_BALANCE_BEFORE = Uint256(0, 0)
    let EXCEEDING_WITHDRAWAL_BALANCE = Uint256(40, 0)
    let POOL_BALANCE_AFTER_DEPOSIT = Uint256(30, 0)
    let POOL_BALANCE_AFTER_WITHDRAWAL = Uint256(15, 0)
    let POOL_BALANCE_AFTER_WITHDRAWAL_ALL = Uint256(0, 0)

    let (pool_balance_before) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_before = POOL_BALANCE_BEFORE

    %{  
        PRANK_ERC721_TOKEN_OWNER = 321
        stop_prank_callable_1 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(PRANK_ERC721_TOKEN_OWNER, target_contract_address=ids.sell_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    %{ 
        stop_prank_callable_1() 
    %}
    ISellPool.depositEth(sell_pool_contract_address, ERC721_TOKEN_OWNER_BALANCE)
    
    let (pool_balance_after_deposit) = ISellPool.getEthBalance(sell_pool_contract_address)
    assert pool_balance_after_deposit = POOL_BALANCE_AFTER_DEPOSIT

    let (pool_balance_erc20_contract) = IERC20.balanceOf(erc20_contract_address, sell_pool_contract_address)
    assert pool_balance_erc20_contract = POOL_BALANCE_AFTER_DEPOSIT

    %{ expect_revert(error_message="Pool ETH balance is unsufficient.") %}
    ISellPool.withdrawEth(sell_pool_contract_address, EXCEEDING_WITHDRAWAL_BALANCE)

    %{ 
        stop_prank_callable_2()
    %}

    return ()
end