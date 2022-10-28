import N32 "mo:base/Nat32";
import I "mo:base/Iter";
import C "mo:base/Char";
import T "mo:base/Text";
import N "mo:base/Nat";

import Debug "mo:base/Debug";



module {
    // Helper from https://forum.dfinity.org/t/subtext-substring-function-in-motoko/11838/2
    public func subText(value : Text, indexStart : Nat, indexEnd : Nat) : Text {
        if (indexStart == 0 and indexEnd >= value.size()) {
            return value;
        }
        else if (indexStart >= value.size()) {
            return "";
        };

        var indexEndValid = indexEnd;
        if (indexEnd > value.size()) {
            indexEndValid := value.size();
        };

        var result : Text = "";
        var iter = I.toArray<Char>(T.toIter(value));
        for (index in I.range(indexStart, indexEndValid - 1)) {
            result := result # C.toText(iter[index]);
        };

        result;
    };

    // Helper from https://forum.dfinity.org/t/motoko-convert-text-123-to-nat-or-int-123/7033/3
    public func textToNat( txt : Text) : Nat {
        Debug.print("textToNat: " # txt);
        assert(txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars){
            let charToNum = N32.toNat(C.toNat32(v)-48);
            assert(charToNum >= 0 and charToNum <= 9);
            num := num * 10 +  charToNum;          
        };
        num;
    };

    public func natTwoDigits (nat: Nat) : Text {
        var text : Text = "";
        if (nat < 10) {
             text #= "0";
        };
        text #= N.toText(nat);
        return text;
    };

    // Date and Time (Zero)
    public type DateTime = {
        year : Nat;
        month : Nat;
        day : Nat;
        hour : Nat;
        minute: Nat;
        sec: Nat;
    };

    // just for IGC Times
    // TODO all possible problems
    public func toDateTime (dateTime: Text): DateTime {
        return {
            day = textToNat(subText(dateTime,0,2));
            month = textToNat(subText(dateTime,2,4));
            year = textToNat(subText(dateTime,4,6));
            hour = textToNat(subText(dateTime,6,8));
            minute = textToNat(subText(dateTime,8,10));
            sec = textToNat(subText(dateTime,10,12));
        };
    };

    public func prettyTime (dt: DateTime) : Text {
        return natTwoDigits(dt.hour)# ":" # natTwoDigits(dt.minute) # ":" # natTwoDigits(dt.sec);
    };

    public func prettyDate(dt: DateTime) : Text {
        return natTwoDigits(dt.year)# "/" # natTwoDigits(dt.month) # "/" # natTwoDigits(dt.day);
    };

    public func prettyDateTime(dt: DateTime) : Text {
        return prettyDate(dt) # "-" # prettyTime(dt);
    };

    public func optionalText (a: ?Text) : Text {
        switch (a) {
            case (null) {
                return "";
            };
            case(?text) {
                return text;
            };
        };
    };
};