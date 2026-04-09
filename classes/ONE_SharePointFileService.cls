/**
* File Name: ONE_SharePointFileService.cls
* Description: Service class to export LPs and upload CSV files to SharePoint (REST classic Files/add)
* Date: 06/02/2026
*
* Copyright: Konozca Consulting
* @author: Adrià Barragán
* Test: ONE_SharePointFileServiceTest
* Modification Log
* ===================================================================================================================
* Version 	Date 			Author 				Modification
* 01 		06/02/2026		Adrià Barragán 		Class creation
* ===================================================================================================================
*/
public with sharing class ONE_SharePointFileService {

    private static final String ENDPOINT_MDT  = 'SHAREPOINT_CREATE_CSV_FILE';
    //PROD
    //private static final String DRIVE_ID = 'b!LeKMdO-ZIEuqjjdihWvH3TcwKR1VFkJEnMGFTpF2GnUyrc7HcV5sQJYW0giNTcMj';
    //Test
    private static final String DRIVE_ID = 'b!u3Jw7fxus0KnDORJK4y-0JRICYq25XFMmY2P7fPkYLDQA_qcRXPzTb5v8pnlx8Gk';

    public static Boolean exportarLineasPlanificacion(String zonaName, List<Id> lpIds) {
        if (String.isBlank(zonaName) || lpIds == null || lpIds.isEmpty()) return false;

        String folderPath = resolveFolder(zonaName);

        Set<Id> idSet = new Set<Id>();
        for (Id i : lpIds) if (i != null) idSet.add(i);
        if (idSet.isEmpty()) return false;

        List<ONE_LineaPlanificacion__c> lps = [
            SELECT
                Id,
                Name,
                ONE_Zona_Operativa_Centro__c,
                ONE_Asesor__c,
                ONE_Caso__r.Name,
                ONE_CentroTrabajo__r.Name,
                ONE_Cliente__c,
                ONE_Servicio__r.Name,
                LastModifiedBy.Name,
                ONE_LugarCeremonia__r.Name,
                ONE_InicioCeremonia__c,
                ONE_FinCeremonia__c,
                ONE_LugarTanatorio__r.Name,
                ONE_InicioTanatorio__c,
                ONE_FinTanatorio__c,
                ONE_SalaTanatorio__r.ONE_Nombre_Base__c,
                ONE_SalaVelacionExterna__c,
                ONE_DireccionVelacion__c,
                ONE_Fecha_Hora_Inicio_Velaci_n__c,
                ONE_FechaHoraFinVelacion__c,
                ONE_DifuntoEnSala__c,
                ONE_NombreTipoDifunto__c,
                ONE_Edad__c,
                ONE_LugarDefuncion__r.Name,
                ONE_CausasDefuncion__c,
                ONE_Destino__r.Name,
                ONE_LugarDestinoFinal__r.Name,
                ONE_Lugar_inhumaci_n__r.Name,
                ONE_FechaHoraDestinoFinal__c,
                ONE_FechaHoraInhumacion__c,
                ONE_FechaHoraIncineracion__c,
                ONE_Lugar_Exhumacion__r.Name,
                Fecha_Hora_exhumaci_n__c,
                Inicio_exhumaci_n__c,
                ONE_Fin_Exhumaci_n__c,
                ONE_C_digo_postal_Exhumaci_n__c,
                ONE_Municipio_Exhumaci_n__c,
                ONE_ConcesionExhumacion__c,
                ONE_Observaciones_Exhumacion__c,
                ONE_Presente_en_Exhumaci_n__c,
                ONE_LicenciaEnterramiento__c,
                ONE_Coche1__r.ONE_Nombre_Base__c,
                ONE_Conductor1__r.ONE_Nombre_Base__c,
                Comentarios_a_Conductor__c,
                ONE_PersonalCeremonia__r.ONE_Nombre_Base__c,
                ONE_Personal_Cremaci_n__r.ONE_Nombre_Base__c,
                ONE_Personal4__r.ONE_Nombre_Base__c,
                ONE_Declarantes__c,
                ONE_ObservacionesGenerales__c,
                ONE_ModeloFeretro__c,
                ONE_Funeraria_Origen_Destino__r.Name,
                ONE_Segmento__c,
                ONE_TipoServicio__c,
                ONE_Unidad_de_Exhumacion__c,
                ONE_TipoUrna__c,
                ONE_FechaHoraProgramada__c
            FROM ONE_LineaPlanificacion__c
            WHERE Id IN :idSet
        ];
        if (lps.isEmpty()) return false;

        List<String> headers = new List<String>{
            'Id',
            'Name',
            'ONE_Zona_Operativa_Centro__c',

            // Básicos
            'ONE_Asesor__c',
            'ONE_Caso__r.Name',
            'ONE_CentroTrabajo__r.Name',
            'ONE_Cliente__c',
            'ONE_Servicio__r.Name',
            'LastModifiedBy.Name',

            // Ceremonia
            'ONE_LugarCeremonia__r.Name',
            'ONE_InicioCeremonia__c',
            'ONE_FinCeremonia__c',

            // Tanatorio / Velación
            'ONE_LugarTanatorio__r.Name',
            'ONE_InicioTanatorio__c',
            'ONE_FinTanatorio__c',
            'ONE_SalaTanatorio__r.ONE_Nombre_Base__c',
            'ONE_SalaVelacionExterna__c',
            'ONE_DireccionVelacion__c',
            'ONE_Fecha_Hora_Inicio_Velaci_n__c',
            'ONE_FechaHoraFinVelacion__c',

            // Difunto
            'ONE_DifuntoEnSala__c',
            'ONE_NombreTipoDifunto__c',
            'ONE_Edad__c',

            // Defunción
            'ONE_LugarDefuncion__r.Name',
            'ONE_CausasDefuncion__c',

            // Destino / Inhumación / Incineración
            'ONE_Destino__r.Name',
            'ONE_LugarDestinoFinal__r.Name',
            'ONE_Lugar_inhumaci_n__r.Name',
            'ONE_FechaHoraDestinoFinal__c',
            'ONE_FechaHoraInhumacion__c',
            'ONE_FechaHoraIncineracion__c',

            // Exhumación
            'ONE_Lugar_Exhumacion__r.Name',
            'Fecha_Hora_exhumaci_n__c',
            'Inicio_exhumaci_n__c',
            'ONE_Fin_Exhumaci_n__c',
            'ONE_C_digo_postal_Exhumaci_n__c',
            'ONE_Municipio_Exhumaci_n__c',
            'ONE_ConcesionExhumacion__c',
            'ONE_Observaciones_Exhumacion__c',
            'ONE_Presente_en_Exhumaci_n__c',
            'ONE_LicenciaEnterramiento__c',

            // Conducción
            'ONE_Coche1__r.ONE_Nombre_Base__c',
            'ONE_Conductor1__r.ONE_Nombre_Base__c',
            'Comentarios_a_Conductor__c',

            // Personal
            'ONE_PersonalCeremonia__r.ONE_Nombre_Base__c',
            'ONE_Personal_Cremaci_n__r.ONE_Nombre_Base__c',
            'ONE_Personal4__r.ONE_Nombre_Base__c',

            // Otros
            'ONE_Declarantes__c',
            'ONE_ObservacionesGenerales__c',
            'ONE_ModeloFeretro__c',
            'ONE_Funeraria_Origen_Destino__r.Name',
            'ONE_Segmento__c',
            'ONE_TipoServicio__c',
            'ONE_Unidad_de_Exhumacion__c',
            'ONE_TipoUrna__c',
            'ONE_FechaHoraProgramada__c'
        };


        Blob csv = ONE_LineasPlanificacionCsvBuilder.build(headers, lps);

        String fileName = buildFileName(zonaName);

        HttpResponse resp = new CreateFileCallout(folderPath, fileName, csv).invokeCallout(true);
        return resp != null && (resp.getStatusCode() == 200 || resp.getStatusCode() == 201);
    }

    private static String buildFileName(String zonaName) {
        String safeZona = String.isBlank(zonaName)
            ? 'SIN_ZONA'
            : zonaName.replace('/', '_').replace(' ', '_').replace('.', '_');

        return 'LPs_' + safeZona + '.csv';
    }

    private class CreateFileCallout extends ONE_Integration.IntegrationCallout {
        CreateFileCallout(String folderPath, String fileName, Blob content) {
            super(ENDPOINT_MDT, ONE_Integration.RestMethod.PUT);
            putHeader(ONE_Integration.HEADER_CT, 'application/octet-stream');
            setResource(buildGraphUploadResource(folderPath, fileName));
            setBodyAsBlob(content);
        }
    }

    private static String buildGraphUploadResource(String folderPath, String fileName) {
        // Path: /v1.0/drives/{driveId}/root:/ANDALUCIA/Z.CADIZ/file.csv:/content
        String fileNameSafe   = urlEncodeFileName(fileName);

        if (String.isBlank(folderPath)) {
            return String.format(
                '/v1.0/drives/{0}/root:/{1}:/content',
                new List<String>{ DRIVE_ID, fileNameSafe }
            );
        }

        String folderPathSafe = encodePathKeepSlashes(folderPath);

        return String.format(
            '/v1.0/drives/{0}/root:/{1}/{2}:/content',
            new List<String>{ DRIVE_ID, folderPathSafe, fileNameSafe }
        );
    }

    private static String encodePathKeepSlashes(String path) {
        String enc = EncodingUtil.urlEncode(path, 'UTF-8').replace('+', '%20');
        return enc.replace('%2F', '/');
    }

    private static String urlEncodeFileName(String s) {
        return EncodingUtil.urlEncode(s, 'UTF-8').replace('+', '%20');
    }

    private static String resolveFolder(String zonaName) {
        List<ONE_Lugar__c> recs = [
            SELECT ONE_Recurso_SharePoint__c
            FROM ONE_Lugar__c 
            WHERE Name = :zonaName
            LIMIT 1
        ];
        if (!recs.isEmpty() && String.isNotBlank(recs[0].ONE_Recurso_SharePoint__c)) {
            return recs[0].ONE_Recurso_SharePoint__c.trim();
        }
        return null;
    }
}