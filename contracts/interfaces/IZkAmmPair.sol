// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IZkAmmPair {
    event Setup(address token0, address token1);
    event AddInitLiquidity(
        uint256 requestId,
        uint256 amount0, 
        uint256 amount1
    );
    event AddLiquidity( 
        uint256 requestId,
        uint256 amount0, 
        uint256 reserve0, 
        uint256 reserve1, 
        uint256 totalSupply
    );
    event RemoveLiquidity(
        uint256 requestId,
        uint256 liquidity, 
        uint256 reserve0, 
        uint256 reserve1, 
        uint256 totalSupply
    );
    event Swap(
        uint256 requestId,
        uint256 amountIn, 
        uint256 reserve0, 
        uint256 reserve1,
        bool zeroForOne
    );

    event LiquidityAdded(
        address payer, 
        address recipient, 
        uint256 amount0, 
        uint256 amount1, 
        uint256 liquidity, 
        uint256 requestId
    );
    event LiquidityRemoved(
        address sender, 
        address recipient, 
        uint256 liquidity, 
        uint256 amount0, 
        uint256 amount1, 
        uint256 requestId
    );
    event Swapped(
        address payer, 
        address recipient, 
        bool zeroForOne, 
        uint256 amountIn, 
        uint256 amountOut, 
        uint256 requestId
    );

    function token0() external view returns (address);
    function token1() external view returns (address);
    function zkGraph() external view returns (address);
    function reserve0() external view returns (uint);
    function reserve1() external view returns (uint);

    function setGraph(address graph) external;

    function addInitLiquidity(
        address recipient, 
        uint256 amount0, 
        uint256 amount1
    ) external;

    function addInitLiquidityCallback(
        uint256 requestId,
        uint256 liquidity
    ) external;

    function addLiquidity(address recipient, uint256 amount0) external;

    function addLiquidityCallback(
        uint256 requestId,
        uint256 amount1,
        uint256 liquidity
    ) external;

    function removeLiquidity(address recipient, uint256 liquidity) external;

    function removeLiquidityCallback(
        uint256 requestId,
        uint256 amount0,
        uint256 amount1
    ) external;

    function swap(address recipient, bool zeroForOne, uint256 amountIn) external;
    
    function swapCallback(
        uint256 requestId,
        uint256 amountOut
    ) external;
}