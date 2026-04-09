global class ONE_TareaDeAlmacenScheduler implements Schedulable {

    public static void scheduleBatch() {
        ONE_TareaDeAlmacenScheduler sched = new ONE_TareaDeAlmacenScheduler();

        System.schedule('Tarea batch 1', '0 0 * * * ?', sched);
        System.schedule('Tarea batch 2', '0 5 * * * ?', sched);
        System.schedule('Tarea batch 3', '0 10 * * * ?', sched);
        System.schedule('Tarea batch 4', '0 15 * * * ?', sched);
        System.schedule('Tarea batch 5', '0 20 * * * ?', sched);
        System.schedule('Tarea batch 6', '0 25 * * * ?', sched);
        System.schedule('Tarea batch 7', '0 30 * * * ?', sched);
        System.schedule('Tarea batch 8', '0 35 * * * ?', sched);
        System.schedule('Tarea batch 9', '0 40 * * * ?', sched);
        System.schedule('Tarea batch 10', '0 45 * * * ?', sched);
        System.schedule('Tarea batch 11', '0 50 * * * ?', sched);
        System.schedule('Tarea batch 12', '0 55 * * * ?', sched);
    }

    public void execute(SchedulableContext sc) {
        ONE_TareaDeAlmacenBatch tareaBatch = new ONE_TareaDeAlmacenBatch();
        Database.executeBatch(tareaBatch, 1);
    }
}