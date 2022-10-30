import N32 "mo:base/Nat32";
import C "mo:base/Char";
import T "mo:base/Text";
import N "mo:base/Nat";
import I "mo:base/Iter";

import Debug "mo:base/Debug";



module {

    // Text fromat helpers
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
        assert (txt.size() > 0);
        var num : Nat = 0;
        let chars = txt.chars();
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

    public func compare (dateTimeA: DateTime, dateTimeB : DateTime) : {#before; #equal; #after} {
        if ((dateTimeA.year < dateTimeB.year)
            or
            (dateTimeA.year == dateTimeB.year
            and dateTimeA.month < dateTimeB.month) 
            or
            (dateTimeA.year == dateTimeB.year
            and dateTimeA.month == dateTimeB.month
            and dateTimeA.day < dateTimeB.day) 
            or
            (dateTimeA.year == dateTimeB.year
            and dateTimeA.month == dateTimeB.month
            and dateTimeA.day == dateTimeB.day
            and dateTimeA.hour < dateTimeB.hour)
            or
            (dateTimeA.year == dateTimeB.year
            and dateTimeA.month == dateTimeB.month
            and dateTimeA.day == dateTimeB.day
            and dateTimeA.hour == dateTimeB.hour
            and dateTimeA.minute < dateTimeB.minute) 
            or
            (dateTimeA.year == dateTimeB.year
            and dateTimeA.month == dateTimeB.month
            and dateTimeA.day == dateTimeB.day
            and dateTimeA.hour == dateTimeB.hour
            and dateTimeA.minute == dateTimeB.minute
            and dateTimeA.sec < dateTimeB.sec)
        ) {
            return #before;
            }; 
        if (dateTimeA.day == dateTimeB.day
        and dateTimeA.month == dateTimeB.month
        and dateTimeA.year == dateTimeB.year
        and dateTimeA.hour == dateTimeB.hour
        and dateTimeA.minute == dateTimeB.minute
        and dateTimeA.sec == dateTimeB.sec
        ) {
            return #equal;
            }
        else {return #after;};
    };

    public func prettyTime (dt: DateTime) : Text {
        return natTwoDigits(dt.hour)# ":" # natTwoDigits(dt.minute) # ":" # natTwoDigits(dt.sec);
    };

    public func prettyDate(dt: DateTime) : Text {
        return "20"#natTwoDigits(dt.year)# "-" # natTwoDigits(dt.month) # "-" # natTwoDigits(dt.day); // TODO remove 20
    };

    public func prettyDateTime(dt: ?DateTime) : Text {
        switch (dt){
            case null {
                "null";
            };
            case (? d) {
                return prettyDate(d) # "T" # prettyTime(d) # "Z";
            };
        };
    };

    // return empty String if null
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

    // which representation used 
    public type Representation = {#json; #html};

    // BBox
    public type BBox = {
        minLat: Float;
        minLon: Float;
        maxLat: Float;
        maxLon: Float;
    };

    //extend the BBox 
    public func extendBBox (boxA: BBox, boxB: BBox) : BBox {
        let minLa = if (boxA.minLat < boxB.minLat) {boxA.minLat} else {boxB.minLat};
        let maxLa = if (boxA.maxLat > boxB.maxLat) {boxA.maxLat} else {boxB.maxLat};
        let minLo = if (boxA.minLon < boxB.minLon) {boxA.minLon} else {boxB.minLon};
        let maxLo = if (boxA.maxLon > boxB.maxLon) {boxA.maxLon} else {boxB.maxLon};
        return {minLat = minLa; maxLat = maxLa; minLon = minLo; maxLon = maxLo};
    };  
};