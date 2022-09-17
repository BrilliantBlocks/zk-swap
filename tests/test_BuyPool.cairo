%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_contract_address

from src.pools.sell.ISellPool import ISellPool, NFT, PoolParams
from tests.helper.IMintPool import IMintPool, Collection

@storage_var
func _buy_pool_contract_address() -> (res: felt) {
}


const C1_NAME = 'COLLECTION 1';
const ERC20_NAME = 'ERC20 Test Contract';
const C1_SYMBOL = 'C1';
const ERC20_SYMBOL = 'ERC20';
const DECIMALS = 18;
const INITIAL_SUPPLY_LOW = 50;
const INITIAL_SUPPLY_HIGH = 0;
const POOL_AND_ERC20_OWNER = 123456789;
const NFT_OWNER_AND_SELLER = 987654321;


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

    context.erc20_contract_address = deploy_contract("./lib/cairo_contracts/src/openzeppelin/token/erc20/presets/ERC20Mintable.cairo", 
            [ 
                ids.ERC20_NAME, ids.ERC20_SYMBOL, ids.DECIMALS, ids.INITIAL_SUPPLY_LOW, ids.INITIAL_SUPPLY_HIGH, ids.POOL_AND_ERC20_OWNER, ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address
    
    context.pool_factory_contract_address = deploy_contract("./tests/helper/MintPool.cairo", 
            [
                ids.POOL_FACTORY_AND_ERC_CONTRACT_OWNER
            ]
        ).contract_address

    context.buy_pool_class_hash = declare("./src/pools/buy/BuyPool.cairo").class_hash

    context.linear_curve_class_hash = declare("./src/bonding_curves/LinearCurve.cairo").class_hash
    %}

    local buy_pool_class_hash;
    local linear_curve_class_hash;
    local c1_contract_address;
    local erc20_contract_address;
    local pool_factory_contract_address;
    %{
        ids.buy_pool_class_hash = context.buy_pool_class_hash
        ids.linear_curve_class_hash = context.linear_curve_class_hash 
        ids.c1_contract_address = context.c1_contract_address 
        ids.erc20_contract_address = context.erc20_contract_address
        ids.pool_factory_contract_address = context.pool_factory_contract_address
    %}

    let NFT_1_1 = Uint256(11, 0);
    let NFT_1_2 = Uint256(12, 0);
    tempvar POOL_PARAMS: PoolParams = PoolParams(price=Uint256(10, 0), delta=1);

    ISellPool.mint(c1_contract_address, NFT_OWNER_AND_SELLER, NFT_1_1);
    ISellPool.mint(c1_contract_address, NFT_OWNER_AND_SELLER, NFT_1_2);

    IMintPool.setPoolClassHash(pool_factory_contract_address, buy_pool_class_hash);

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable_1 = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.pool_factory_contract_address)
    %}
    let (buy_pool_contract_address) = IMintPool.mint(
        pool_factory_contract_address, linear_curve_class_hash, erc20_contract_address
    );
    %{ stop_prank_callable_1() %}

    _buy_pool_contract_address.write(buy_pool_contract_address);

    %{
        POOL_AND_ERC20_OWNER = 123456789
        stop_prank_callable_2 = start_prank(POOL_AND_ERC20_OWNER, target_contract_address=ids.buy_pool_contract_address)
    %}
    ISellPool.setPoolParams(buy_pool_contract_address, POOL_PARAMS);
    %{ stop_prank_callable_2() %}

    return ();
}


@external
func test_initialization_pool_factory{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local pool_factory_contract_address;
    local buy_pool_class_hash;
    %{
        ids.pool_factory_contract_address = context.pool_factory_contract_address 
        ids.buy_pool_class_hash = context.buy_pool_class_hash
    %}

    let (POOL_FACTORY_OWNER) = get_contract_address();

    let (factory_owner) = IMintPool.getFactoryOwner(pool_factory_contract_address);
    let (pool_type_class_hash) = IMintPool.getPoolTypeClassHash(pool_factory_contract_address);
    let (
        collection_array_len: felt, collection_array: Collection*
    ) = IMintPool.getAllCollectionsFromAllPools(pool_factory_contract_address);

    assert factory_owner = POOL_FACTORY_OWNER;
    assert pool_type_class_hash = buy_pool_class_hash;
    assert collection_array_len = 0;

    return ();
}