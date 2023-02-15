import N32 "mo:base/Nat32";
import C "mo:base/Char";
import T "mo:base/Text";
import N "mo:base/Nat";
import I "mo:base/Iter";
import R "mo:base/Result";
import Debug "mo:base/Debug";




module {

    // Errors
    public type HelperError = {#parseError; #numberToBig};

    // which representation used 
    public type Representation = {#json; #html; #undefined};

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
    public func textToNat( txt : Text) : R.Result <Nat, HelperError> {
        if (txt.size() <= 0) {
            Debug.print("helper textToNat: Text Size Error" # debug_show(txt.size()));
            return #err(#parseError);
        };
        var num : Nat = 0;
        let chars = txt.chars();
        for (v in chars){
            let charToNum = N32.toNat(C.toNat32(v)-48);
            if (charToNum < 0 or charToNum > 9) {
                Debug.print("helper textToNat: Number Error" # debug_show(v) # " Code: " # debug_show(charToNum));
                return #err(#parseError);
            };
            num := num * 10 +  charToNum;         
        };
        #ok(num);
    };

    // TODO: Handle big numbers
    public func natTwoDigits (nat: Nat) : R.Result <Text, HelperError> {
        var text : Text = "";
        if (nat > 99) {
            return #err(#numberToBig);
        };
        if (nat < 10) {
             text #= "0";
        };
        text #= N.toText(nat);
        return #ok(text);
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