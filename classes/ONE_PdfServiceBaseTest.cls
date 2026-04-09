@isTest
/*
    Test class for the the ONE_PdfServiceBase class.
    This test class was created as an auxiliary test class in order to cover the code of data structure definitions that isn't covered by other test classes.
*/
public class ONE_PdfServiceBaseTest {

    @isTest
    public static void pdfServiceBaseDataStructureDefinitions() {

        ONE_PdfServiceBase.Field field = new ONE_PdfServiceBase.Field(
            'label',
            'value',
            0,
            false,
            'fontWeight'
        );

        ONE_PdfServiceBase.Block block = new ONE_PdfServiceBase.Block(
            new List<ONE_PdfServiceBase.Field>{field},
            'firstColumnWidthPercent',
            false,
            'header'
        );


        ONE_PdfServiceBase.Header header = new ONE_PdfServiceBase.Header(
            block, 
            block,
            block
        );

        ONE_PdfServiceBase.TableItem tableItem = new ONE_PdfServiceBase.TableItem(
            new List<ONE_PdfServiceBase.Field>{field},
            0
        );


        ONE_PdfServiceBase.Table table = new ONE_PdfServiceBase.Table(
            'title', 
            new List<ONE_PdfServiceBase.TableItem>{tableItem}
        );
    }
}