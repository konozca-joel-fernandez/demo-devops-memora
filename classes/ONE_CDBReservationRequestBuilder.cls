public with sharing class ONE_CDBReservationRequestBuilder {

    ONE_CDBReservationService.ReservationParameters reservationParameters;
    public ONE_CDBReservationRequestBuilder() {
        reservationParameters = new ONE_CDBReservationService.ReservationParameters();
    }

    public static ONE_CDBReservationRequestBuilder newInstance() {
        return new ONE_CDBReservationRequestBuilder();
    }

    public ONE_CDBReservationService.ReservationParameters get() {
        return reservationParameters;
    }

    public ONE_CDBReservationRequestBuilder setRcprosol(String value) {
        reservationParameters.rcprosol = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcususol(String value) {
        reservationParameters.rcususol = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRctipsol(String value) {
        reservationParameters.rctipsol = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRctipinh(String value) {
        reservationParameters.rctipinh = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcnom(String value) {
        reservationParameters.rcnom = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRccog1(String value) {
        reservationParameters.rccog1 = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcsexe(String value) {
        reservationParameters.rcsexe = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcnaixe(String value) {
        reservationParameters.rcnaixe = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcprovi(String value) {
        reservationParameters.rcprovi = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRccaumor(String value) {
        switch on value {
            when 'COVID' {
                reservationParameters.rccaumor = 'I';
            }
            when 'Natural' {
                reservationParameters.rccaumor = 'E';
            }
            when else {
                reservationParameters.rccaumor = value;
            }
        }
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcdatdef(String value) {
        reservationParameters.rcdatdef = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRchordef(String value) {
        reservationParameters.rchordef = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcestdif(String value) {
        reservationParameters.rcestdif = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRctipser(String value) {
        reservationParameters.rctipser = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcdatinc(String value) {
        reservationParameters.rcdatinc = value;
        return this;
    }
    
    public ONE_CDBReservationRequestBuilder setRchorinc(String value) {
        reservationParameters.rchorinc = value;
        return this;
    }
    
    public ONE_CDBReservationRequestBuilder setRcdatinh(String value) {
        reservationParameters.rcdatinh = value;
        return this;
    }
    
    public ONE_CDBReservationRequestBuilder setRchorinh(String value) {
        reservationParameters.rchorinh = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcceminc(String value) {
        reservationParameters.rcceminc = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRctelef(String value) {
        reservationParameters.rctelef = value;
        return this;
    }

    public ONE_CDBReservationRequestBuilder setRcceminh(String value) {
        reservationParameters.rcceminh = value;
        return this;
    }
    
    public ONE_CDBReservationRequestBuilder setRcdifunt(String value) {
        reservationParameters.rcdifunt = value;
        return this;
    }

   /*public ONE_CDBReservationRequestBuilder setDominicana(String value) {
        reservationParameters.Dominicana = value;
        return this;
    }*/
}