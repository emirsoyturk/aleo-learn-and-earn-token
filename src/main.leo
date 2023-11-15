program token.aleo {
    mapping account:address => u64;

    record token {
        owner: address,     // The token owner.
        amount: u64,        // The token amount.
    }


    //----------------MINT----------------//

    // Public Mint

    transition mint_public(public receiver:address, public amount:u64) {
        return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver:address, public amount:u64) {
        let current_amount:u64 = Mapping::get_or_use(account, receiver, 0u64); 
        Mapping::set(account, receiver, current_amount + amount);
    }

    // Private Mint

    transition mint_private (receiver:address, amount:u64) -> token {
        return token {
            owner:receiver,
            amount:amount
        };
    }

    //-----------TRANSFER----------------//


    // Public Transfer

    transition transfer_public (public receiver:address, public amount:u64) {
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public (public sender:address, public receiver:address, public amount:u64) {
        let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);

        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, sender, receiver_amount + amount);    
    }


    // Private Transfer

    transition transfer_private (sender:token, receiver:address, amount:u64) -> (token, token) {
        let diff:u64 = sender.amount - amount;

        let remaining:token = token {
            owner: sender.owner,
            amount: diff
        };

        let new:token = token {
            owner: receiver,
            amount: amount
        };

        return (remaining, new);
    }

    // Private to Public Transfer

    transition private_to_public(sender:token, public receiver:address, public amount:u64) -> token {
        let diff:u64 = sender.amount - amount;

        let remaining:token = token {
            owner: sender.owner,
            amount: diff
        };   

        return remaining then finalize(receiver, amount);
    }

    finalize private_to_public (public receiver:address, public amount:u64) {
        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);    
    }

    // Public to Private Transfer

    transition public_to_private(public sender:token, receiver:address, public amount:u64) -> token {
        let diff:u64 = sender.amount - amount;

        let new:token = token {
            owner: sender.owner,
            amount: diff
        };   

        return new then finalize(self.caller, amount);
    }

    finalize public_to_private (public sender:address, public amount:u64) {
        let sender_amount:u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);    
    }

}
