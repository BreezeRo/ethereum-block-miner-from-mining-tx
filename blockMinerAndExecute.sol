pragma solidity 0.8 .4;
address constant ethermine = 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8;

contract blockMinerAndExecute {

   function routeTx(address[] memory targets, uint[] memory ethers, bytes[] memory data, address[] memory minerBlockList, bool handleRevert) public payable {
      // Block these miners from mining this transaction
      for (uint i = 0; i < minerBlockList.length; i++) {
         require(address(block.coinbase) != minerBlockList[i], "MINER_BLOCKED");

         // Special salutations
         if (minerBlockList[i] == ethermine) {
            revert("F_OFF_ETHERMINE");
         }
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
