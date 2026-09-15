@isTest
private class AccountServiceTest {

    @isTest
    static void testHighAmountDiscount() {
        Test.startTest();
        Decimal discount = AccountService.calculateDiscount(1000);
        Test.stopTest();

        Assert.areEqual(100, discount, 'El descuento para importes de 1000 o superiores debe ser del 10%.');
    }

    @isTest
    static void testLowAmountDiscount() {
        Test.startTest();
        Decimal discount = AccountService.calculateDiscount(500);
        Test.stopTest();

        Assert.areEqual(25, discount, 'El descuento para importes menores a 1000 debe ser del 5%.');
    }

    @isTest
    static void testZeroAndNullAmount() {
        Test.startTest();
        Decimal discountNull = AccountService.calculateDiscount(null);
        Decimal discountZero = AccountService.calculateDiscount(0);
        Decimal discountNegative = AccountService.calculateDiscount(-100);
        Test.stopTest();

        Assert.areEqual(0, discountNull, 'El descuento para importes nulos debe ser 0.');
        Assert.areEqual(0, discountZero, 'El descuento para importes 0 debe ser 0.');
        Assert.areEqual(0, discountNegative, 'El descuento para importes negativos debe ser 0.');
    }
}