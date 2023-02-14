%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import FALSE, TRUE

from lib.cairo_contracts.src.openzeppelin.token.erc721.IERC721 import IERC721
from lib.cairo_contracts.src.openzeppelin.token.erc20.IERC20 import IERC20

from src.pools.IPool import IPool, NFT, PoolParams
from tests.helper.IMintPool import Collection, IMintPool


@storage_var
func _trade_pool_contract_address() -> (res: felt) {
}


const C1_NAME = 'COLLECTION 1';
const C2_NAME = 'COLLECTION 2';
const C1_SYMBOL = 'C1';
const C2_SYMBOL = 'C2';
const ERC20_NAME = 'ERC20 Test Contract';
const ERC20_SYMBOL = 'ERC20';
const DECIMALS = 4;
const INITIAL_SUPPLY_LOW = 500000;
const INITIAL_SUPPLY_HIGH = 0;
const POOL_OWNER_AND_LP = 123456789;
const NFT_TRADER = 987654321;


@view
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let (POOL_FACTORY_AND_ERC_CONTRACT_OWNER) = get_contract_address();

    %{
    context.c1_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C1_NAME, ids.C1_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
            ).contract_address

    context.c2_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo", 
            [ 
                ids.C2_NAME, ids.C2_SYMBOL, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
            ).contract_address

    context.erc20_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20Mintable.cairo", 
            [ 
                ids.ERC20_NAME, ids.ERC20_SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.POOL_OWNER_AND_LP, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address
    
    context.pool_factory_contract_address = deploy_contract("./tests/helper/MintPool.cairo", 
            [
                ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

    context.trade_pool_class_hash = declare("./src/pools/TradePool.cairo").class_hash

    context.linear_curve_class_hash = declare("./src/bonding_curves/LinearCurve.cairo").class_hash
    %}

    local trade_pool_class_hash;
    local linear_curve_class_hash;
    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    local pool_factory_contract_address;
    %{
        ids.trade_pool_class_hash = context.trade_pool_class_hash
        ids.linear_curve_class_hash = context.linear_curve_class_hash 
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
        ids.pool_factory_contract_address = context.pool_factory_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_2_3 = Uint256(23, 0);
    let NFT_2_4 = Uint256(24, 0);
    let DEPOSIT_BALANCE = Uint256(400000, 0);
    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=10000);

    IPool.mint(c1_contract_address, POOL_OWNER_AND_LP, NFT_1_1);
    IPool.mint(c1_contract_address, POOL_OWNER_AND_LP, NFT_1_2);
    IPool.mint(c2_contract_address, POOL_OWNER_AND_LP, NFT_2_1);
    IPool.mint(c2_contract_address, NFT_TRADER, NFT_2_2);
    IPool.mint(c2_contract_address, NFT_TRADER, NFT_2_3);
    IPool.mint(c2_contract_address, NFT_TRADER, NFT_2_4);

    IPool.mint(erc20_contract_address, NFT_TRADER, Uint256(500000, 0));

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable_1 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.pool_factory_contract_address)
    %}
    let (trade_pool_contract_address) = IMintPool.mint(
        pool_factory_contract_address, trade_pool_class_hash, linear_curve_class_hash, erc20_contract_address
    );
    %{ stop_prank_callable_1() %}

    _trade_pool_contract_address.write(trade_pool_contract_address);

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable_2 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_3 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, trade_pool_contract_address, DEPOSIT_BALANCE);
    %{ stop_prank_callable_2() %}

    IPool.setPoolParams(trade_pool_contract_address, POOL_PARAMS);
    IPool.depositEth(trade_pool_contract_address, DEPOSIT_BALANCE);
    %{ stop_prank_callable_3() %}

    return ();
}


@external
func test_initialization_pool_factory{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local pool_factory_contract_address;
    local trade_pool_class_hash;
    %{
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
        ids.trade_pool_class_hash = context.trade_pool_class_hash
    %}

    let (POOL_FACTORY_OWNER) = get_contract_address();
    let (trade_pool_contract_address) = _trade_pool_contract_address.read();

    let (factory_owner) = IMintPool.getFactoryOwner(pool_factory_contract_address);
    let (pool_type_class_hash) = IMintPool.getPoolTypeClassHash(pool_factory_contract_address, trade_pool_contract_address);
    let (
        collection_array_len: felt, collection_array: Collection*
    ) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address);

    assert factory_owner = POOL_FACTORY_OWNER;
    assert pool_type_class_hash = trade_pool_class_hash;
    assert collection_array_len = 0;

    return ();
}


@external
func test_initialization_ERC_contracts{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    %{
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NFT_2_2 = Uint256(22, 0);
    let NFT_2_3 = Uint256(23, 0);
    let NFT_2_4 = Uint256(24, 0);

    let (trade_pool_contract_address) = _trade_pool_contract_address.read();
    let (c1_balance) = IERC721.balanceOf(c1_contract_address, POOL_OWNER_AND_LP);
    let (c2_balance) = IERC721.balanceOf(c2_contract_address, POOL_OWNER_AND_LP);
    let (erc20_balance_lp) = IERC20.balanceOf(erc20_contract_address, POOL_OWNER_AND_LP);
    let (erc20_balance_trader) = IERC20.balanceOf(erc20_contract_address, NFT_TRADER);
    let (erc20_balance_pool) = IERC20.balanceOf(erc20_contract_address, trade_pool_contract_address);
    let (c1_token_owner) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (c2_token_owner) = IERC721.ownerOf(c2_contract_address, NFT_2_1);
    let (erc20_total_supply) = IERC20.totalSupply(erc20_contract_address);

    assert c1_balance = Uint256(2, 0);
    assert c2_balance = Uint256(1, 0);
    assert erc20_balance_lp = Uint256(100000, 0);
    assert erc20_balance_trader = Uint256(500000, 0);
    assert erc20_balance_pool = Uint256(400000, 0);
    assert erc20_total_supply = Uint256(1000000, 0);
    assert c1_token_owner = POOL_OWNER_AND_LP;
    assert c2_token_owner = POOL_OWNER_AND_LP;

    return ();
}


@external
func test_getPoolConfig_with_expected_output{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local pool_factory_contract_address;
    %{ ids.pool_factory_contract_address = context.pool_factory_contract_address %}

    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(100000, 0), delta=10000);

    let (trade_pool_contract_address) = _trade_pool_contract_address.read();
    let (pool_factory) = IPool.getPoolFactory(trade_pool_contract_address);
    let (pool_params: PoolParams) = IPool.getPoolConfig(trade_pool_contract_address);
    let (erc20_balance_pool) = IPool.getEthBalance(trade_pool_contract_address);

    let (high, low) = split_felt(trade_pool_contract_address);
    let trade_pool_contract_address_token = Uint256(low, high);
    let (pool_owner) = IERC721.ownerOf(
        pool_factory_contract_address, trade_pool_contract_address_token
    );

    assert pool_factory = pool_factory_contract_address;
    assert pool_params.price = POOL_PARAMS.price;
    assert pool_params.delta = POOL_PARAMS.delta;
    assert pool_owner = POOL_OWNER_AND_LP;
    assert erc20_balance_pool = Uint256(400000, 0);

    return ();
}


@external
func test_addSupportedCollections{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local c1_contract_address;
    local c2_contract_address;
    %{
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address 
    %}

    let (trade_pool_contract_address) = _trade_pool_contract_address.read();
    let (c1_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c1_contract_address);
    let (c2_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c2_contract_address);

    assert c1_is_supported = FALSE;
    assert c2_is_supported = FALSE;

    let (COLLECTION_ARRAY: felt*) = alloc();
    assert COLLECTION_ARRAY[0] = c1_contract_address;
    assert COLLECTION_ARRAY[1] = c2_contract_address;

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IPool.addSupportedCollections(trade_pool_contract_address, 2, COLLECTION_ARRAY);
    %{ stop_prank_callable() %}

    let (c1_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c1_contract_address);
    let (c2_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c2_contract_address);

    assert c1_is_supported = TRUE;
    assert c2_is_supported = TRUE;

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IPool.removeSupportedCollections(trade_pool_contract_address, 2, COLLECTION_ARRAY);
    %{ stop_prank_callable() %}

    let (c1_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c1_contract_address);
    let (c2_is_supported) = IPool.checkCollectionSupport(trade_pool_contract_address, c2_contract_address);

    assert c1_is_supported = FALSE;
    assert c2_is_supported = FALSE;

    return ();
}


@external
func test_sellNfts{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local c2_contract_address;
    local erc20_contract_address;
    %{
        ids.c2_contract_address = context.c2_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let (trade_pool_contract_address) = _trade_pool_contract_address.read();

    let NFT_2_2 = Uint256(22, 0);
    let NFT_2_3 = Uint256(23, 0);
    let NFT_2_4 = Uint256(24, 0);

    let (COLLECTION_ARRAY: felt*) = alloc();
    assert COLLECTION_ARRAY[0] = c2_contract_address;

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=c2_contract_address, id=NFT_2_2);
    assert NFT_ARRAY[1] = NFT(address=c2_contract_address, id=NFT_2_3);
    assert NFT_ARRAY[2] = NFT(address=c2_contract_address, id=NFT_2_4);

    let (erc20_balance_trader_before) = IERC20.balanceOf(erc20_contract_address, NFT_TRADER);
    let (erc20_balance_pool_before) = IERC20.balanceOf(erc20_contract_address, trade_pool_contract_address);
    let (pool_eth_balance_before) = IPool.getEthBalance(trade_pool_contract_address);
    let (token_owner_before) = IERC721.ownerOf(c2_contract_address, NFT_2_2);
    let (all_collections_before_len, all_collections_before) = IPool.getAllCollections(trade_pool_contract_address);
    let (all_nfts_of_c2_before_len, all_nfts_of_c2_before) = IPool.getAllNftsOfCollection(trade_pool_contract_address, c2_contract_address);
    assert erc20_balance_trader_before = Uint256(500000, 0);
    assert erc20_balance_pool_before = Uint256(400000, 0);
    assert pool_eth_balance_before = Uint256(400000, 0);
    assert token_owner_before = NFT_TRADER;
    assert all_collections_before_len = 0;
    assert all_nfts_of_c2_before_len = 0;

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IPool.addSupportedCollections(trade_pool_contract_address, 1, COLLECTION_ARRAY);
    %{ stop_prank_callable() %}

    %{
        NFT_TRADER = 987654321
        stop_prank_callable_1 = start_prank(NFT_TRADER, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_2 = start_prank(NFT_TRADER, target_contract_address=ids.trade_pool_contract_address)
    %}
    IERC721.approve(c2_contract_address, trade_pool_contract_address, NFT_2_2);
    IERC721.approve(c2_contract_address, trade_pool_contract_address, NFT_2_3);
    IERC721.approve(c2_contract_address, trade_pool_contract_address, NFT_2_4);
    %{
        stop_prank_callable_1() 
    %}
    IPool.sellNfts(trade_pool_contract_address, 3, NFT_ARRAY);
    %{ stop_prank_callable_2() %}

    let (erc20_balance_trader_after) = IERC20.balanceOf(erc20_contract_address, NFT_TRADER);
    let (erc20_balance_pool_after) = IERC20.balanceOf(erc20_contract_address, trade_pool_contract_address);
    let (pool_eth_balance_after) = IPool.getEthBalance(trade_pool_contract_address);
    let (c2_nft_owner_after) = IERC721.ownerOf(c2_contract_address, NFT_2_2);
    let (all_collections_after_len, all_collections_after) = IPool.getAllCollections(trade_pool_contract_address);
    let (all_nfts_of_c2_after_len, all_nfts_of_c2_after) = IPool.getAllNftsOfCollection(trade_pool_contract_address, c2_contract_address);
    assert erc20_balance_trader_after = Uint256(770000, 0);
    assert pool_eth_balance_after = Uint256(130000, 0);
    assert erc20_balance_pool_after = Uint256(130000, 0);
    assert c2_nft_owner_after = trade_pool_contract_address;
    assert all_collections_after_len = 1;
    assert all_collections_after[0] = c2_contract_address;
    assert all_nfts_of_c2_after_len = 3;
    assert all_nfts_of_c2_after[0] = NFT_2_2;
    assert all_nfts_of_c2_after[1] = NFT_2_3;
    assert all_nfts_of_c2_after[2] = NFT_2_4;

    return ();
}


@external
func test_buyNfts{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    local c1_contract_address;
    local c2_contract_address;
    local erc20_contract_address;
    %{
        ids.c1_contract_address = context.c1_contract_address 
        ids.c2_contract_address = context.c2_contract_address
        ids.erc20_contract_address = context.erc20_contract_address
    %}

    let (trade_pool_contract_address) = _trade_pool_contract_address.read();
    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    let NFT_2_1 = Uint256(21, 0);
    let NEW_PRICE = Uint256(130000, 0);
    let TOTAL_PRICE = Uint256(330000, 0);
    let POOL_ETH_BALANCE_AFTER = Uint256(730000, 0);

    let (COLLECTION_ARRAY: felt*) = alloc();
    assert COLLECTION_ARRAY[0] = c1_contract_address;
    assert COLLECTION_ARRAY[1] = c2_contract_address;

    let (NFT_ARRAY: NFT*) = alloc();
    assert NFT_ARRAY[0] = NFT(address=c1_contract_address, id=NFT_1_1);
    assert NFT_ARRAY[1] = NFT(address=c1_contract_address, id=NFT_1_2);
    assert NFT_ARRAY[2] = NFT(address=c2_contract_address, id=NFT_2_1);

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IPool.addSupportedCollections(trade_pool_contract_address, 2, COLLECTION_ARRAY);
    %{ stop_prank_callable() %}

    %{
        POOL_OWNER_AND_LP = 123456789
        stop_prank_callable_1 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.c1_contract_address)
        stop_prank_callable_2 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.c2_contract_address)
        stop_prank_callable_3 = start_prank(POOL_OWNER_AND_LP, target_contract_address=ids.trade_pool_contract_address)
    %}
    IERC721.approve(c1_contract_address, trade_pool_contract_address, NFT_1_1);
    IERC721.approve(c1_contract_address, trade_pool_contract_address, NFT_1_2);
    IERC721.approve(c2_contract_address, trade_pool_contract_address, NFT_2_1);
    %{
        stop_prank_callable_1() 
        stop_prank_callable_2()
    %}
    IPool.addNftToPool(trade_pool_contract_address, 3, NFT_ARRAY);
    %{ stop_prank_callable_3() %}

    %{
        NFT_TRADER = 987654321
        stop_prank_callable_1 = start_prank(NFT_TRADER, target_contract_address=ids.erc20_contract_address)
        stop_prank_callable_2 = start_prank(NFT_TRADER, target_contract_address=ids.trade_pool_contract_address)
    %}
    IERC20.approve(erc20_contract_address, trade_pool_contract_address, TOTAL_PRICE);
    %{ stop_prank_callable_1() %}
    IPool.buyNfts(trade_pool_contract_address, 3, NFT_ARRAY);
    %{ stop_prank_callable_2() %}

    let (pool_eth_balance_after) = IPool.getEthBalance(trade_pool_contract_address);
    let (new_pool_params) = IPool.getPoolConfig(trade_pool_contract_address);
    let (pool_nft_balance_after) = IERC721.balanceOf(c1_contract_address, trade_pool_contract_address);
    let (nft_owner_after) = IERC721.ownerOf(c1_contract_address, NFT_1_1);
    let (erc20_balance_nft_buyer_after) = IERC20.balanceOf(erc20_contract_address, NFT_TRADER);

    assert pool_eth_balance_after = POOL_ETH_BALANCE_AFTER;
    assert new_pool_params.price = NEW_PRICE;
    assert pool_nft_balance_after = Uint256(0, 0);
    assert nft_owner_after = NFT_TRADER;
    assert erc20_balance_nft_buyer_after = Uint256(170000, 0);

    return ();
}