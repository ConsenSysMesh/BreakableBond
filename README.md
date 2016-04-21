## The BreakableBond contract
The BreakableBond contract represents a simple yet novel design for Ethereum contracts that implement linkages inspired by chemical bonds. On the blockchain, these bonds are realized not through the behavior of electrons and atoms but through the use of ether, Ethereum's cryptocurrency.

In the BreakableBond contract, two parties (Ethereum addresses) submit a designated amount of ether to the contract, and after both have done this the bond becomes active. During this time, the ether that was submitted to the contract stays in place and is unavailable for other uses. The "strength" of the bond is proportional to the amount of ether in it. When it is active, the bond encourages coordination between the two parties, in proportion to the amount of ether in the bond.

The bond remains active until one of the parties breaks it. When this happens, the stored ether is returned to each party, and the bond becomes inactive; the financial incentive for coordination between the two parties disappears.

The BreakableBond contract's stored ether is the essence of the bond. Indeed, the contract itself is quite small and does not (and cannot) directly effect any change on the outside world. Even on the blockchain, its action is minimal. Nevertheless, a system's awareness of its bonds and the value stored in them can guide its behavior.

Interestingly, this implementation of the contract also allows third parties (addresses) to break the bond. To do this, the third party must send to the contract an amount of ether equal to the total amount of ether stored by the bond. When this happens, the bond is broken, and the bond parties receive *double* the amount of ether they paid to form the bond. This is a cost that is imposed on the third party for breaking a bond it is not party to, and a reparation to the bond parties for the inconvenience of having their bond broken.

It is envisioned that the Ethereum-aware systems of the future will utilize BreakableBond contracts to coordinate behavior among their components or with other such systems. These systems may take part in numerous bonds of various values or durations. These bonds, and the distribution of ether across them, represents a new dimension in the state of a system that would not have been possible without Ethereum.

Note: the protocal for establishing a BreakableBond is unspecified.

The BreakableBond contract can be modified in the following parameters:
* The number of parties
* The amount of ether that each party needs to submit to activate the bond
* The permitted ways of breaking the bond

## Source code
```
contract BreakableBond {

    address party1;
    address party2;

    uint amount;

    uint party1balance;
    uint party2balance;

    enum Status { Pending, Active, Broken, Cancelled }
    Status status;

    // create the contract
    function BreakableBond(address p1, address p2, uint amt) {
        party1 = p1;
        party2 = p2;
        amount = amt;
        status = Status.Pending;
    }

    // add funds to form the bond
    // called by both party1 and party2
    function add_funds() {
        if (status != Status.Pending) {
            return;
        }
        if (msg.sender == party1) {
            party1balance += msg.value;
        }
        else if (msg.sender == party2) {
            party2balance += msg.value;
        }
        if (party1balance >= amount && party2balance >= amount) {
            status = Status.Active;
        }
    }

    // break the bond
    // called by either party1, party2, or a third party
    function breakit() {
        if (status != Status.Active) {
            return;
        }
        if (msg.sender == party1 || msg.sender == party2) {
            party1.send(party1balance);
            party1balance = 0;
            party2.send(party2balance);
            party2balance = 0;
            status = Status.Broken;
        } else if (msg.value >= party1balance + party2balance) {
            party1.send(party1balance * 2);
            party1balance = 0;
            party2.send(party2balance * 2);
            party2balance = 0;
            status = Status.Broken;
        }
    }

    // cancel a bond before it becomes active (before the other party adds funds)
    function cancel() {
        if (status != Status.Pending) {
            return;
        }
        if (msg.sender == party1 || msg.sender == party2) {
            party1.send(party1balance);
            party1balance = 0;
            party2.send(party2balance);
            party2balance = 0;
            status = Status.Cancelled;
        }
    }

    // getters
    function get_party1() returns (address) {
        return party1;
    }

    function get_party2() returns (address) {
        return party2;
    }

    function get_amount() returns (uint) {
        return amount;
    }

    function get_party1_balance() returns (uint) {
        return party1balance;
    }

    function get_party2_balance() returns (uint) {
        return party2balance;
    }

    function get_status() returns (Status) {
         return status;
    }
}
```
