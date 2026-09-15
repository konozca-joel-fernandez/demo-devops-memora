public with sharing class AccountService {
    
    /**
     * Calcula un porcentaje de descuento según el importe proporcionado.
     */
    public static Decimal calculateDiscount(Decimal amount) {
        if (amount == null || amount <= 0) {
            return 0;
        }
        
        if (amount >= 1000) {
            return amount * 0.10; // 10% de descuento
        }
        
        return amount * 0.05; // 5% de descuento
    }
}