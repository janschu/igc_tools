    import H "helper";
    import R "mo:base/Result";
    import O "mo:base/Option";
    
    module {
        // Errors
        public type DateTimeError = {#formatError;#nullError};

        // Date and Time (Zulu)
        public type DateTime = {
            year : Nat;
            month : Nat;
            day : Nat;
            hour : Nat;
            minute: Nat;
            sec: Nat;
        };

        // just for IGC Times (ddMMyyhhmmss)
        public func igcToDateTime (dateTime: Text): R.Result <DateTime, DateTimeError>  {
            if (dateTime.size() > 12) {
                return #err(#formatError);
            };           
            let dd = H.textToNat(H.subText(dateTime,0,2));
            let MM = H.textToNat(H.subText(dateTime,2,4));
            let yy = H.textToNat(H.subText(dateTime,4,6));
            let hh = H.textToNat(H.subText(dateTime,6,8));
            let mm = H.textToNat(H.subText(dateTime,8,10));
            let ss = H.textToNat(H.subText(dateTime,10,12));

            // all errors are parsing errors
            if(R.isErr(dd) or R.isErr(MM) or R.isErr(yy) or R.isErr(hh) or R.isErr(mm) or R.isErr(ss)){
                return #err(#formatError);
            };           
            return #ok ({
                day = O.get <Nat> (R.toOption(dd), 0);
                month = O.get <Nat> (R.toOption(MM), 0);
                year = O.get <Nat> (R.toOption(yy), 0);
                hour = O.get <Nat> (R.toOption(hh), 0);
                minute = O.get <Nat> (R.toOption(mm), 0);
                sec = O.get <Nat> (R.toOption(ss), 0);
                });
        };

        // compares two dateTimes
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

        // formats Time according to OGC Time 
        private func prettyTime (dt: DateTime) : Text {
            // ther shall be no errors in conerting dateTime to String -> traps
            var pretty : Text = "";
            switch (H.natTwoDigits(dt.hour)) {
                case (#err(_)){assert false}; 
                case (#ok(text)){pretty #= text;}
            };
            pretty #= ":";
            switch (H.natTwoDigits(dt.minute)) {
                case (#err(_)){assert false};
                case (#ok(text)){pretty #= text;}
            };
            pretty #= ":";
            switch (H.natTwoDigits(dt.sec)) {
                case (#err(_)){assert false};
                case (#ok(text)){pretty #= text;}
            };
            return pretty;
        };

        // formats Date according to OGC Date 
        private func prettyDate(dt: DateTime) : Text {
            var pretty : Text = "20"; // TODO change and include 2000 in dateTime
            switch (H.natTwoDigits(dt.year)) {
                case (#err(_)){assert false}; 
                case (#ok(text)){pretty #= text;}
            };
            pretty #= "-";
            switch (H.natTwoDigits(dt.month)) {
                case (#err(_)){assert false};
                case (#ok(text)){pretty #= text;}
            };
            pretty #= "-";
            switch (H.natTwoDigits(dt.day)) {
                case (#err(_)){assert false};
                case (#ok(text)){pretty #= text;}
            };
            return pretty;
        };

        // formats 
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
    }