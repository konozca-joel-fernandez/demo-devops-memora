global with sharing class ONE_UdianasIntegrationService {

    private static final String METADATA_NAME = 'UDIANAS_CREATE';

    // Callout
    public class UdianasCreateCallout extends ONE_Integration.IntegrationCallout {

        public UdianasCreateCallout(String requestBodyJson, String apiKey) {
            super(METADATA_NAME, ONE_Integration.RestMethod.POST);
            putHeader('Content-Type', 'application/json');
            putHeader('X-Api-Key', apiKey);
            setBody(requestBodyJson);
        }

        public override HttpResponse invokeCallout() {
            if (!isActive()) {
                throw new ONE_Exception(
                    ONE_Exception.ExceptionType.INTEGRATION,
                    'Integration endpoint ' + METADATA_NAME + ' is inactive'
                );
            }

            HttpRequest req = buildRequest();
            HttpResponse res = new Http().send(req);

            if (isLogActive()) {
                ONE_IntegrationLog log = new ONE_IntegrationLog(
                    'ONE_UdianasIntegrationService',
                    req.getBody(),
                    res != null ? res.getBody() : null,
                    req.getMethod(),
                    req.getEndpoint(),
                    ONE_IntegrationLog.Direction.OUTBOUND
                );
                ONE_IntegrationLog.commitLog(log, true, true);
            }

            return res;
        }
    }

    public static HttpResponse createUdiana(String requestJson, String apiKey) {
        UdianasCreateCallout callout =
            new UdianasCreateCallout(requestJson, apiKey);
        return callout.invokeCallout();
    }

    private class InsuranceInfo {
        public Id accountId;
        public Boolean needsInsurance;
        public InsuranceInfo(Id aId, Boolean needs) {
            accountId = aId;
            needsInsurance = needs;
        }
    }

    private static Account resolveInsuranceAccountFromPayor(Account payor) {
        if (payor == null) return null;

        if (payor.Parent != null
            && payor.Parent.Parent != null
            && payor.Parent.Parent.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {
            return payor.Parent.Parent;
        }
        if (payor.Parent != null
            && payor.Parent.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {
            return payor.Parent;
        }
        if (payor.ONE_Nivel_Jerarquia_Cuentas__c == 'Agrupación Salesforce') {
            return payor;
        }
        return payor;
    }

    // Invocable
    @InvocableMethod(label='Crear Udiana' description='Crea un registro en Udianas a partir de un servicio')
    public static List<FlowOutputs> invokeIntegration(List<FlowInputs> inputs) {

        List<FlowOutputs> outputs = new List<FlowOutputs>();
        if (inputs == null || inputs.isEmpty()) return outputs;

        Set<Id> ids = new Set<Id>();
        for (FlowInputs fi : inputs) {
            if (fi != null && fi.recordId != null) {
                ids.add(fi.recordId);
            }
        }

        // Query servicios
        Map<Id, ONE_Expediente__c> serviciosById =
            new Map<Id, ONE_Expediente__c>(
                [SELECT Id,
                        ONE_Servicio__c,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id,
                        ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c
                 FROM ONE_Expediente__c
                 WHERE Id IN :ids
                 WITH SECURITY_ENFORCED]
            );

        Set<Id> asegurados = new Set<Id>();
        for (ONE_Expediente__c s : serviciosById.values()) {
            if (s.ONE_Servicio__c == 'Asegurado/Acuerdo') {
                asegurados.add(s.Id);
            }
        }

        // Presupuestos por servicio
        List<ONE_Presupuesto__c> presupuestos = [
            SELECT Id, ONE_Expediente__c
            FROM ONE_Presupuesto__c
            WHERE ONE_Expediente__c IN :asegurados
            WITH SECURITY_ENFORCED
        ];


        Set<Id> presupuestoIds = new Set<Id>();
        for (ONE_Presupuesto__c p : presupuestos) {
            if (p != null && p.Id != null) presupuestoIds.add(p.Id);
        }

        // Insurance info por servicio: (insuranceAccountId, needsInsurance)
        Map<Id, InsuranceInfo> insuranceInfoByServicio = new Map<Id, InsuranceInfo>();

        if (!presupuestoIds.isEmpty()) {
            List<ONE_Orden_De_Venta__c> odvs = [
                SELECT Id,
                       CreatedDate,
                       ONE_Presupuesto__c,
                       ONE_Presupuesto__r.ONE_Expediente__c,
                       ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c,
                       ONE_Presupuesto__r.ONE_Estado_Facturacion_Presupuesto__c,
                       ONE_Estado_De_La_Orden_de_Venta__c,
                       ONE_Orden_de_Venta_Cancelada__c,
                       ONE_Pagador_Compania__c,
                       ONE_Pagador_Compania__r.Id,
                       ONE_Pagador_Compania__r.ONE_Nivel_Jerarquia_Cuentas__c,
                       ONE_Pagador_Compania__r.ONE_InsuranceHashId__c,
                       ONE_Pagador_Compania__r.Parent.Id,
                       ONE_Pagador_Compania__r.Parent.ONE_Nivel_Jerarquia_Cuentas__c,
                       ONE_Pagador_Compania__r.Parent.ONE_InsuranceHashId__c,
                       ONE_Pagador_Compania__r.Parent.Parent.Id,
                       ONE_Pagador_Compania__r.Parent.Parent.ONE_Nivel_Jerarquia_Cuentas__c,
                       ONE_Pagador_Compania__r.Parent.Parent.ONE_InsuranceHashId__c
                FROM ONE_Orden_De_Venta__c
                WHERE ONE_Presupuesto__c IN :presupuestoIds
                  AND ONE_Presupuesto__r.ONE_Tipo_De_Presupuesto__c = 'Presupuesto servicio completo'
                  AND ONE_Presupuesto__r.ONE_Estado_Facturacion_Presupuesto__c = 'Facturado (Orden de Venta creada)'
                  AND ONE_Estado_De_La_Orden_de_Venta__c != 'Abonado'
                  AND ONE_Orden_de_Venta_Cancelada__c = false
                  AND ONE_Pagador_Compania__c != null
                ORDER BY CreatedDate DESC
            ];

            for (ONE_Orden_De_Venta__c odv : odvs) {
                if (odv == null || odv.ONE_Presupuesto__r == null) continue;

                Id sId = odv.ONE_Presupuesto__r.ONE_Expediente__c;
                if (sId == null || !serviciosById.containsKey(sId)) continue;

                if (insuranceInfoByServicio.containsKey(sId)) continue;
                
                Account insuranceAccount = resolveInsuranceAccountFromPayor(odv.ONE_Pagador_Compania__r);

                if (insuranceAccount == null) {
                    insuranceInfoByServicio.put(sId, new InsuranceInfo(null, false));
                    continue;
                }

                Boolean needs = String.isBlank(insuranceAccount.ONE_InsuranceHashId__c);
                insuranceInfoByServicio.put(sId, new InsuranceInfo(insuranceAccount.Id, needs));
            }
        }

        // Estructuras de control
        Map<Id, List<Id>> pendingByZona = new Map<Id, List<Id>>();
        Map<Id, List<Id>> pendingByInsuranceAccount = new Map<Id, List<Id>>();
        Set<Id> needsWait = new Set<Id>();
        Set<Id> enqueued = new Set<Id>();

        // Clasificacion
        for (ONE_Expediente__c s : serviciosById.values()) {

            Id zonaId =
                (s.ONE_Centro_Del_Expediente__r != null
                 && s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r != null
                 && s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r != null)
                ? s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.Id
                : null;

            String enterpriseHash =
                (s.ONE_Centro_Del_Expediente__r != null
                 && s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r != null
                 && s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r != null)
                ? s.ONE_Centro_Del_Expediente__r.ONE_Lugar__r.ONE_Lugar_Superior__r.ONE_EnterpriseHashId__c
                : null;

            Boolean needEnterprise = (zonaId != null && String.isBlank(enterpriseHash));

            InsuranceInfo ii = insuranceInfoByServicio.get(s.Id);
            Boolean needInsurance = (ii != null && ii.accountId != null && ii.needsInsurance == true);

            if (needEnterprise) {
                if (!pendingByZona.containsKey(zonaId)) pendingByZona.put(zonaId, new List<Id>());
                pendingByZona.get(zonaId).add(s.Id);
                needsWait.add(s.Id);
            }

            if (needInsurance) {
                if (!pendingByInsuranceAccount.containsKey(ii.accountId)) {
                    pendingByInsuranceAccount.put(ii.accountId, new List<Id>());
                }
                pendingByInsuranceAccount.get(ii.accountId).add(s.Id);
                needsWait.add(s.Id);
            }
        }

        // Servicios que pertenecen a algún grupo de INSURANCE pendiente
        Set<Id> blockedByInsurance = new Set<Id>();
        for (List<Id> lst : pendingByInsuranceAccount.values()) {
            if (lst != null) blockedByInsurance.addAll(lst);
        }

        // Lideres por InsuranceAccount (primero)
        for (Id accId : pendingByInsuranceAccount.keySet()) {
            List<Id> lst = pendingByInsuranceAccount.get(accId);
            Id leader = (lst != null && !lst.isEmpty()) ? lst[0] : null;

            if (leader != null && !enqueued.contains(leader)) enqueued.add(leader);
        }

        // Lideres por ZONA (pero NO si están bloqueados por INSURANCE)
        for (Id zonaId : pendingByZona.keySet()) {
            List<Id> lst = pendingByZona.get(zonaId);
            if (lst == null || lst.isEmpty()) continue;

            Id leader = null;
            for (Id sid : lst) {
                if (!blockedByInsurance.contains(sid)) {
                    leader = sid;
                    break;
                }
            }

            if (leader != null) enqueued.add(leader);
        }

        // Servicios sin espera
        for (Id servicioId : serviciosById.keySet()) {
            Boolean willEnqueueBecauseNoWait = !needsWait.contains(servicioId);
            if (willEnqueueBecauseNoWait) enqueued.add(servicioId);
        }

        // Encolado final
        System.enqueueJob(new ONE_UdianasCreateQueueable(new List<Id>(enqueued)));

        // Outputs
        for (FlowInputs fi : inputs) {
            FlowOutputs fo = new FlowOutputs();
            fo.success = true;
            fo.statusCode = 0;
            fo.udianaId = null;
            fo.message = enqueued.contains(fi.recordId) ? 'Enqueued' : 'Pending';
            outputs.add(fo);
        }

        return outputs;
    }

    // Inputs / Outputs
    public class FlowInputs {
        @InvocableVariable(
            label='Servicio Id'
            description='Id del servicio a enviar a Udianas'
        )
        public Id recordId;
    }

    public class FlowOutputs {
        @InvocableVariable(label='Success')
        public Boolean success;
        @InvocableVariable(label='Status Code')
        public Integer statusCode;
        @InvocableVariable(label='UdianaId')
        public String udianaId;
        @InvocableVariable(label='Message')
        public String message;
    }
}