// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract RaffleLottery{
    address public manager;
    address[] public players;
    bool public winnerHasBeenChosen;
    address public winner;

    constructor(){
        manager = msg.sender;
    }

    function joinRaffle() public payable {
        require(msg.value >= 0.5 ether);

        // In case a winner was just chosen, resest the values.
        winnerHasBeenChosen = false;
        winner = address(0);

        // One entry per 0.5 boba. Max entries per transaction is 3.
        uint numEntriesSent = msg.value / 0.5 ether;
        uint numEntries = 3;
        if (numEntriesSent < numEntries) {
            numEntries = numEntriesSent;
        }

        // Add one entry per 0.5 boba.
        for (uint i = 0; i < numEntries; i++){
            players.push(msg.sender);
        }

        // Automatically choose a winner if the total number of players exceeds 10.
        if (players.length > 10){
            selectWinner();
            //winnerHasBeenChosen = true;
        }
    }

    function numPlayers() public view returns (uint){
        return players.length;
    }

    function selectWinnerRestricted() public requireManager {
        selectWinner();
    }

    function selectWinner() private {
        uint indexOfWinner = pseudoRandom() % players.length;

        // Send boba to the winner.
        payable(players[indexOfWinner]).transfer(address(this).balance);

        // Set the value of the winner's address.
        winner = players[indexOfWinner];
        winnerHasBeenChosen = true;

        // Reset the collection of players so it can start over.
        players = new address[](0);
    }

    function getRaffleCurrentValue() public view returns (uint) {
        return address(this).balance;
    }

    function getParticipants() public view returns (address[] memory){
        return players;
    }

    function pseudoRandom() private view returns (uint){
        // Not truly random. Good enough for some fun.
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    modifier requireManager(){
        require(msg.sender == manager);
        _;
    }
}