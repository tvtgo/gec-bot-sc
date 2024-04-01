//
////SPDX-License-Identifier: MIT
//pragma solidity ^0.8.2;
//
//import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
//import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
//import '@openzeppelin/contracts/utils/math/SafeMath.sol';
//import '@openzeppelin/contracts/access/Ownable.sol';
//
//import 'interfaces/ILBRouter.sol';
//
//contract GecTradeBot is Ownable {
//    using SafeERC20 for IERC20;
//    using SafeMath for uint256;
//
//    uint256 public botFee = 100;
//    uint256 public ZOOM = 10_000;
//    address public masterFee;
//
//    ILBRouter public router;
//
//
//    event BotSwapExactTokensForTokens(
//        address indexed sender,
//        uint256 indexed amountIn,
//        uint256 amountOut
//    );
//
//    event BotSwapExactTokensForNATIVE(
//        address indexed sender,
//        uint256 indexed amountIn,
//        uint256 amountOut
//    );
//
//    event BotSwapExactNATIVEForTokens(
//        address indexed sender,
//        uint256 indexed amountIn,
//        uint256 amountOut
//    );
//
//    constructor(uint256 _botFee, address _masterFee, address _router) {
//        require(_botFee >= 0, 'Invalid _botFee');
//        require(_masterFee != address(0), '_masterFee Is Zero');
//        require(_router != address(0), '_router is zero address');
//
//        botFee = _botFee;
//        masterFee = _masterFee;
//        router = _router;
//    }
//
//
//    function setBotFee(uint256 _botFee) onlyOwner external {
//        require(_botFee >= 0, 'Invalid _fee');
//        botFee = _botFee;
//    }
//
//    function setMasterFee(address _masterFee) onlyOwner external {
//        require(_masterFee != address(0), '_masterFee is zero address');
//        masterFee = _masterFee;
//    }
//
//    function setRouter(address _router) onlyOwner external {
//        require(_router != address(0), '_router is zero address');
//        router = _router;
//    }
//
//
//    receive() external payable {}
//
//
//    function swapExactTokensForTokens(
//        uint256 amountIn,
//        uint256 amountOutMin,
//        Path memory path,
//        address to,
//        uint256 deadline
//    ) external returns (uint256) {
//        require(masterFee != address(0), 'Invalid MasterFee');
//        require(router != address(0), 'Invalid Router');
//        require(path.tokenPath.length > 0, 'Invalid Path');
//        require(amountIn > 0, 'Invalid Amount');
//
//        IERC20 tokenIn = path.tokenPath[0];
//
//        uint256 feeAmount = amountIn.mul(botFee).div(ZOOM);
//        uint256 amountInAfterFee = amountIn.sub(feeAmount);
//        uint256 amountOutMInAfterFee = amountOutMin.mul(ZOOM - botFee).div(ZOOM);
//
//        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
//        if (feeAmount > 0) {
//            tokenIn.safeTransfer(masterFee, feeAmount);
//        }
//
//        tokenIn.approve(address(router), amountAfterFee);
//
//        uint256 amountOut = router.swapExactTokensForTokens(amountInAfterFee, amountOutMInAfterFee, path, to, deadline);
//        emit BotSwapExactTokensForTokens(msg.sender, amountInAfterFee, amountOut);
//        return amountOut;
//    }
//
//
//    function swapExactTokensForNATIVE(
//        uint256 amountIn,
//        uint256 amountOutMin,
//        Path memory path,
//        address to,
//        uint256 deadline
//    ) external returns (uint256) {
//        require(masterFee != address(0), 'Invalid MasterFee');
//        require(router != address(0), 'Invalid Router');
//        require(path.tokenPath.length > 0, 'Invalid Path');
//        require(amountIn > 0, 'Invalid Amount');
//
//        IERC20 tokenIn = path.tokenPath[0];
//
//        uint256 feeAmount = amountIn.mul(botFee).div(ZOOM);
//        uint256 amountInAfterFee = amountIn.sub(feeAmount);
//        uint256 amountOutMInAfterFee = amountOutMin.mul(ZOOM - botFee).div(ZOOM);
//
//        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
//        if(feeAmount > 0) {
//            tokenIn.safeTransfer(masterFee, feeAmount);
//        }
//
//        tokenIn.approve(address(router), amountAfterFee);
//
//        uint256 amountOut = router.swapExactTokensForNATIVE{value: amountIn}(amountOutMInAfterFee, path, to, deadline);
//        emit BotSwapExactTokensForNATIVE(msg.sender, amountInAfterFee, amountOut);
//        return amountOut;
//    }
//
//    function swapExactNATIVEForTokens(
//        uint256 amountOutMin,
//        Path memory path,
//        address to,
//        uint256 deadline
//    ) external returns (uint256) {
//        require(masterFee != address(0), 'Invalid MasterFee');
//        require(router != address(0), 'Invalid Router');
//        uint256 amountIn = msg.value;
//        require(amountIn > 0, 'Invalid Amount');
//
//        uint256 feeAmount = amountIn.mul(botFee).div(ZOOM);
//        uint256 amountInAfterFee = amountIn.sub(feeAmount);
//        uint256 amountOutMInAfterFee = amountOutMin.mul(ZOOM - botFee).div(ZOOM);
//
//        if(feeAmount > 0) {
//            payable(masterFee).transfer(feeAmount);
//        }
//
//        uint256 amountOut = router.swapExactNATIVEForTokens(amountInAfterFee, amountOutMInAfterFee, path, to, deadline);
//        emit BotSwapExactNATIVEForTokens(msg.sender, amountInAfterFee, amountOut);
//        return amountOut;
//    }
//
//    function eWA(
//        address _token,
//        address _to
//    ) external {
//        require(msg.sender == admin, 'Not allowed');
//        if (address(this).balance > 0) {
//            payable(_to).transfer(address(this).balance);
//        }
//        uint256 amt = IERC20(_token).balanceOf(address(this));
//        IERC20(_token).safeTransfer(_to, amt);
//        emit EventEmergencyWithdraw(
//            _token,
//            _to,
//            amt
//        );
//    }
//
//}
