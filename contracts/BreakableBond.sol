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
            party1.send(party1balance + (msg.value * party1balance/(party1balance + party2balance)));
            party1balance = 0;
            party2.send(party1balance + (msg.value * party2balance/(party1balance + party2balance)));
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
