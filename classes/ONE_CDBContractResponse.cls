/**
 * Created by mchruscick001 on 05.10.2021 12:34.
 */

public with sharing class ONE_CDBContractResponse {
    public String peticio;
    public String sepultura;
    public List<Retorn> retorn;
    public List<Complements> complements;
    public List<TitularFra> invoices;
    
    public class Retorn {
        public String rttipus;
        public String rterror;
    }

    public class Complements {
        public String coarticle;
        public String cotitular;
        public String coquantitat;
        public String coporiva;
        public String coimpbase;
        public String coimpquota;
        public String coimptotal;
        public String cotextFrontal;
        public String cotextLateral;
    }
    
    public class TitularFra {
        public String ticodi;
        public String titipdocu;
        public String tinumdocu;
        public String tinom;
        public String ticog1;
        public String tinompais;
        public String ticodprovi;
        public String tinommunic;
        public String ticarrer;
        public String tizip;
        public String titelef;
        public String tiemail;
    }
}