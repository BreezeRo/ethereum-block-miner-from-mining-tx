pragma solidity 0.8 .4;
address constant ethermine = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;

interface IERC20 {
   function balanceOf(address account) external view returns(uint256);

   function transfer(address recipient, uint256 amount) external returns(bool);

   function allowance(address owner, address spender) external view returns(uint256);

   function approve(address spender, uint256 amount) external returns(bool);

   function transferFrom(address sender, address recipient, uint256 amount) external payable returns(bool);

   event Transfer(address indexed from, address indexed to, uint256 value);
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract blockMinerAndExecute {

   function routeTx(address[] memory targets, uint[] memory ethers, bytes[] memory data, address[] memory minerBlockList, address[] memory requireToken, uint256[] memory requireTokenAmount, address[] memory approveToken, address[] memory approveTarget, uint256[] memory approveAmount, bool handleRevert) public payable {
      // Block these miners from mining this transaction
      for (uint i = 0; i < minerBlockList.length; i++) {
         require(address(block.coinbase) != minerBlockList[i], "MINER_BLOCKED");

         // Special salutations
         if (minerBlockList[i] == ethermine) {
            revert("F_OFF_ETHERMINE");
         }
      }

      // Receive required tokens if any
      for (uint i = 0; i < requireToken.length; i++) {
         IERC20(requireToken[i]).transferFrom(msg.sender, address(this), requireTokenAmount[i]);
      }

      // Process approvals if any
      for (uint i = 0; i < approveToken.length; i++) {
         require(approveAmount[i] <= IERC20(approveToken[i]).balanceOf(address(this)), "CANT_APPROVE_>_SENT");
         IERC20(approveToken[i]).approve(approveTarget[i], approveAmount[i]);
      }

      // Execute payload
      for (uint i = 0; i < targets.length; i++) {
         (bool success, ) = targets[i].call {
            value: ethers[i]
         }(data[i]);
         if (!success && handleRevert) revert('ROUTER_ERROR');
      }
   }
}
