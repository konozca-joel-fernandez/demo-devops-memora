/**
 * Created by msulek003 on 13.04.2021.
 */

public with sharing class ONE_MomentoServiceConstants {
    
    // Variables for Momento agrupations
    public static String PRESTACION_SERVICO_MOMENT = 'Prestación del servicio';
    public static String VELACION_SERVICO_MOMENT = 'Velatorio';
    public static String CEREMONIA_SERVICO_MOMENT = 'Ceremonia';
    public static String ARTE_FLORAL_SERVICO_MOMENT = 'Arte Floral';
    public static String PRODUCTOS_RECUERDO_SERVICO_MOMENT = 'Productos del recuerdo';
    public static String TRASLADOS_SERVICO_MOMENT = 'Traslados';
    public static String SEGUIMOS_ACOMPANANDOTE_SERVICO_MOMENT = 'Seguimos acompañándote';
    public static String COMUNICACION_SERVICO_MOMENT = 'Comunicación';
    public static String DESTINO_INCINERACION_SERVICO_MOMENT = 'Destino Final Incineración';
    public static String DESTINO_INHUMACION_SERVICO_MOMENT = 'Destino final inhumación';
    public static String OTROS_SERVICO_MOMENT = 'Otros servicios';
	
    //Creation of the Momento's list
    public static List<String> MOMENTOS_NAMES= new List<String>{
        PRESTACION_SERVICO_MOMENT,
        VELACION_SERVICO_MOMENT,
        CEREMONIA_SERVICO_MOMENT,
        ARTE_FLORAL_SERVICO_MOMENT,
        PRODUCTOS_RECUERDO_SERVICO_MOMENT,
        TRASLADOS_SERVICO_MOMENT,
        SEGUIMOS_ACOMPANANDOTE_SERVICO_MOMENT,
        COMUNICACION_SERVICO_MOMENT,
        DESTINO_INCINERACION_SERVICO_MOMENT,
        DESTINO_INHUMACION_SERVICO_MOMENT,
        OTROS_SERVICO_MOMENT
    };
	
    // Creation of the "Prestación de Servicio" aggrupation to the "Prestación del servicio" Momento
    public static List<String> PRESTACION_SERVICO_AGRUPACION_LIST = new List<String>{
        'Prestación',
        'Féretros',
        'Recepciones',
        'Prestación del servicio concesiones'
    };
    
    /*Creation of the "Prestación de Servicio" categories, its important to use the same aggrupation name
	define previously at the moment of indicate the categories that should be inside*/    
    public static Map<String, List<String>> PRESTACION_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Prestación'=> new List<String>{ //Add to Prestación aggrupation the necesary categories
            'Recogida',
            'Tipos de prestación',
            'Otros tipos de prestación',
            'Tramites',
            'Tratamientos',
            'Personal',
            'Vehiculo',
            'Servicios y productos adicionales'
        },
        'Féretros' => new List<String>{//Add to Féretros aggrupation the necesary categories
            'Féretros Adultos',
            'Féretros Párvulos',
            'Otros féretros',
            'Materiales preparación féretro',
            'Ornamentos féretros religiosos',
            'Ornamentos féretros laicos',
            'Otros complementos féretro'
        },
        'Recepciones'=> new List<String>{//Add to Recepciones agrupation the necesary categories
            'Prod y servicios vinculados a las recepciones'
        },
        'Prestación del servicio concesiones'=> new List<String>{//Add to Prestación del servicio concesiones agrupation the necesary categories
            'Prestación del servicio Portugalete',
            'Prestación del servicio Getafe',
            'Prestación del servicio Pinto',
            'Prestación del servicio Alcorcón',
            'Prestación del servicio Torrelodones',
            'Prestación del servicio Fuenlabrada',
            'Prestación del servicio Velilla'
                
        }
    };
    
    // Creation of the "Velación de Servicio" aggrupation
    public static List<String> VELACION_SERVICO_AGRUPACION_LIST = new List<String>{
        'Composición del velatorio',
        'Composición velatorio concesiones'
    };
    
    /*Creation of the "Velación de Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/  
    public static Map<String, List<String>> VELACION_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Composición del velatorio'=> new List<String>{//Add to Composición del velatorio aggrupation the necesary categories
            'Salas Velatorio',
            'Otros tipos de velatorios',
            'Productos y servicios en velatorio',
            'Servicios complementarios'
        },
        'Composición velatorio concesiones'=> new List<String>{//Add to Composición velatorio concesiones agrupation the necesary categories
            'Composición velatorio Fuenlabrada',
            'Composición velatorio Getafe',
            'Composición velatorio Alcorcón',
            'Composición velatorio Pinto',
            'Composición velatorio Torrelodones',
            'Composición velatorio Zentolen',
            'Composición velatorio Sabadell',
            'Composición velatorio Torrelaguna',
            'Composición velatorio Hoyo de Manzanares',
            'Composición velatorio El Boalo',
            'Composición velatorio Mataelpino',
            'Composición velatorio Colmenar Viejo',
            'Composición velatorio La Cabrera',
            'Composición velatorio Guadalix Sierra',
            'Composición velatorio Manzanares El Real',
            'Composición velatorio Soto del Real',
            'Composición velatorio Boalo, Matalpino, Cerceda',
            'Composición velatorio Talamanca del Jarama',
            'Composición velatorio El vellon',
            'Composición velatorio Galdakao',
            'Composición velatorio Basauri',
            'Composición velatorio Portugalete',
            'Composición velatorio Velilla',
            'Composición velatorio Venturada'
        }
    };

    // Creation of the "Ceremonia de Servicio" aggrupation        
    public static List<String> CEREMONIA_SERVICO_AGRUPACION_LIST = new List<String>{
        'Ceremonial',
        'Recordatorios',
        'Música',
        'Personalización de la ceremonia',
        'Vehículos ceremonia',
        'Composición ceremonia concesiones'
    };
        
    /*Creation of the "Ceremonia de Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/          
    public static Map<String, List<String>> CEREMONIA_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Ceremonial'=> new List<String>{//Add to Ceremonial aggrupation the necesary categories
            'Salas de ceremonias',
            'Tipos de ceremonia'
        },
        'Recordatorios' => new List<String>{//Add to Recordatorios aggrupation the necesary categories
            'Tipos de recordatorios'
        },
        'Música'=> new List<String>{//Add to Música aggrupation the necesary categories
            'Servicio musical',
            'Otros productos musicales'
        },
        'Personalización de la ceremonia'=> new List<String>{//Add to Personalización de la ceremonia aggrupation the necesary categories
            'Servicios personalización ceremonia',
            'Servicios audiovisuales y streaming'
        },
        'Vehículos ceremonia'=> new List<String>{//Add to Vehículos ceremonia aggrupation the necesary categories
            'C. Vehículos ceremonia'
        },
        'Composición ceremonia concesiones'=> new List<String>{//Add to Composición ceremonia concesiones aggrupation the necesary categories
            'Composición ceremonia Sabadell',
            'Ceremonial CB'
        }
    };

    // Creation of the "Arte Florar Servicio" aggrupation              
    public static List<String> ARTE_FLORAL_SERVICO_AGRUPACION_LIST = new List<String>{
        'Catalogo de Flores',
        'Flores para cada momento',
        'Servicios Florales'
    };

    /*Creation of the "Arte Florar Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/         
    public static Map<String, List<String>> ARTE_FLORAL_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Catalogo de Flores'=> new List<String>{//Add to Catalogo de Flores aggrupation the necesary categories
            'Coronas y medallones',
            'Centros y Raquettes ECO',
            'Ramos',
            'Detalles',
            'Otros producto florales',
            'Flores compañias',
            'Servicios Florales'
        },
        'Flores para cada momento' => new List<String>{//Add to Flores para cada momento aggrupation the necesary categories
            'Flores velatorio',
            'Flores ceremonia',
            'Flores cementerio'
        },
        'Servicios Florales'=> new List<String>{//Add to Servicios Florales aggrupation the necesary categories
            'Otros servicios florales'
        }
    };

    // Creation of the "Producto Recuerdo Servicio" aggrupation 
    public static List<String> PRODUCTOS_RECUERDO_SERVICO_AGRUPACION_LIST = new List<String>{
        'Joyas'
    };

    /*Creation of the "Producto Recuerdo Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/ 
    public static Map<String, List<String>> PRODUCTOS_RECUERDO_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Joyas'=> new List<String>{//Add to Joyas aggrupation the necesary categories
            'Joyas huella',
            'Joyas con carbono',
            'Diamantes'
        }
    };

    // Creation of the "Traslado Servicio" aggrupation        
    public static List<String> TRASLADOS_SERVICO_AGRUPACION_LIST = new List<String>{
        'Preparacion arca traslados',
        'Servicios vinculados al traslado'
          
    };

    /*Creation of the "Traslado Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/        
    public static Map<String, List<String>> TRASLADOS_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Servicios vinculados al traslado'=> new List<String>{//Add to Servicios vinculados al traslado aggrupation the necesary categories
            'Costes desplazamiento',
            'Trámites',
            'Servicios de traslado'

        },
        'Preparacion arca traslados'=> new List<String>{//Add to Preparacion arca traslados aggrupation the necesary categories
            'Materiales de traslado'
        }
    };

    // Creation of the "Seguimos Acompañandote Servicio" aggrupation   
    public static List<String> SEGUIMOS_ACOMPANANDOTE_SERVICO_AGRUPACION_LIST = new List<String>{
        'Productos y servicios post'
    };

    /*Creation of the "Seguimos Acompañandote Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/   
    public static Map<String, List<String>> SEGUIMOS_ACOMPANANDOTE_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Productos y servicios post'=> new List<String>{//Add to Productos y servicios post aggrupation the necesary categories
            'Acompañamiento',
            'Tramites y gestoria',
            'Servicios vinculados a las cenizas',
            'Servicios alquiler columbarios'
        }
    };

    // Creation of the "Comunicación Servicio" aggrupation        
    public static List<String> COMUNICACION_SERVICO_AGRUPACION_LIST = new List<String>{
        'Esquela en prensa',
        'Esquela de reparto',
        'Otros medios'
    };

    /*Creation of the "Comunicación Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/         
    public static Map<String, List<String>> COMUNICACION_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Esquela en prensa'=> new List<String>{//Add to Esquela en prensa aggrupation the necesary categories
            'Otras esquelas en periódico',
            'Esquela ABC',
            'Esquela Alto Aragón',
            'Esquela Canarias 7',
            'Esquela Diari de Girona',
            'Esquela Diari mes Tarragona',
            'Esquela Diari Tarragona',
            'Esquela Diario Berria',
            'Esquela Diario de avisos',
            'Esquela Diario de Burgos',
            'Esquela Diario de Cádiz',
            'Esquela Diario de Jerez',
            'Esquela Diario de León',
            'Esquela Diario de Navarra',
            'Esquela Diario de Sevilla',
            'Esquela Diario de Tarragona',
            'Esquela Diario Gara',
            'Esquela Diario Noticias',
            'Esquela Diario Vasco',
            'Esquela Digital desde Soria',
            'Esquela El Correo',
            'Esquela El Día',
            'Esquela El Mundo',
            'Esquela El País',
            'Esquela El Periódico',
            'Esquela El Periódico de Aragón',
            'Esquela El Punt de Girona',
            'Esquela Heraldo de Aragón',
            'Esquela Heraldo de Soria',
            'Esquela La Nueva Crónica de León',
            'Esquela LA PROVINCIA',
            'Esquela La Rioja',
            'Esquela La Vanguardia',
            'Esquela La Voz de Lanzarote',
            'Esquela Las Provincias',
            'Esquela Levante',
            'Esquela Canarias',
            'Esquela Regió 7',
            'Esquela El Punt Avui',
            'Esquela El Segre',
            'Esquela La Mañana',
            'Esquela Ara',
            'Esquela Nueva Alcarria',
            'Esquela Norte Castilla',
            'Esquela EL ADELANTO BAÑEZANO',
            'Esquela Noticias de Gipuzkoa',
            'Esquela Diario Hitza',
            'Noticias de Álava',
            'Esquela Diario Deia',
            'Esquela Diario KRONIKA',
            'Esquela Diario de Sabadell',
            'Esquela Lancelot medios',
            'Esquela Diario Montañés',
            'Esquela La Voz de Medina',
            'Esquela Alerta',
			'Esquela Diario Palentino',
            'Esquelas La Opinión'
        },
        'Esquela de reparto' => new List<String>{//Add to Esquela de reparto aggrupation the necesary categories
             'Esquela de reparto'   
        },
        'Otros medios' => new List<String>{//Add to Otros medios aggrupation the necesary categories
            'Avisadores',
            'Cuñas de radio'
        }
    };

    // Creation of the "Destino Incineracion Servicio" aggrupation         
    public static List<String> DESTINO_INCINERACION_SERVICO_AGRUPACION_LIST = new List<String>{
        'Incineración',
        'Urnas',
        'Relicarios',
        'D. final incineración concesiones'
    };

    /*Creation of the "Destino Incineracion Servicio / Destino Final Incineración " categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/         
    public static Map<String, List<String>>  DESTINO_INCINERACION_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Incineración'=> new List<String>{//Add to Incineración aggrupation the necesary categories
            'Salas de despedida',
            'Trámites incineración',
            'Servicios vinculados incineración',
            'Complementarios incineración',
            'Crematorios',
            'Destino Final Incineración Cementiris Barcelona',
            'Destino final incineración Alcorcón',
            'Destino final incineración Fuenlabrada',
            'Destino final incineración Pinto',
            'Destino final incineración Getafe',
            'Destino final incineración Zentolen',
            'Destino final incineración Sabadell',
            'Destino final incineración Colmenar Viejo',
            'Destino final incineración Andra Mari - Galdakao',
            'Destino final incineración Portugalete',
            'Destino final incineración Bilbao',
            'Trámites y tasas CB'
        },
        'Urnas' => new List<String>{//Add to Urnas aggrupation the necesary categories
            'Urnas adultos',
            'Urnas párvulos',
            'Complementos urna',
            'Urnas CB'
        },
        'Relicarios' => new List<String>{//Add to Relicarios aggrupation the necesary categories
            'Relicarios \'mini urnas\'',
            'Relicarios minerales',
            'Joyas relicario',
            'Otros relicarios',
            'Joyas Relicario CB',
            'Relicarios CB'
        },
        'D. final incineración concesiones' => new List<String>{//Add to D. final incineración concesiones aggrupation the necesary categories
            'D. final incineración Fuenlabrada',
            'D. final incineración Getafe',
            'D. final incineración Alcorcón',
            'D. final incineración Pinto'
        }
    };

    // Creation of the "Destino Inhumacion Servicio" aggrupation  
    public static List<String> DESTINO_INHUMACION_SERVICO_AGRUPACION_LIST = new List<String>{
        'Inhumación',
        'Arte Funerario',
        'D. final inhumación concesiones'
    };

    /*Creation of the "Destino Inhumacion Servicio / Destino final inhumación" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/          
    public static Map<String, List<String>> DESTINO_INHUMACION_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Inhumación'=> new List<String>{//Add to Inhumación the necesary categories
            'Trámites y tasas cementerio',
            'Prod y servicios vinculado al cementerio',
            'Destino final inhumación Cementiris Barcelona',
            'Destino final inhumación Alcorcón',
            'Destino final inhumación Pinto',
            'Destino final inhumación Fuenlabrada',
            'Destino final inhumación Getafe',
            'Destino final inhumación Sallent',
            'Destino final inhumación Torrelodones',
            'Destino final inhumación Sabadell',
            'Destino final inhumación Bilbao',
            'Destino final inhumación Barakaldo'   
                
        },
        'Arte Funerario' => new List<String>{//Add to Arte Funerario aggrupation the necesary categories
            'Lápidas',
            'Complementos lápida',
            'Trámites arte funerario'
        },
        'D. final inhumación concesiones' => new List<String>{//Add to D. final inhumación concesiones  aggrupation the necesary categories
            'Adjudicaciones Getafe',
            'Adjudicaciones Alcorcón',
            'Adjudicaciones Pinto',
            'Inhumaciones/Exhumaciones Fuenlabrada',
            'Inhumaciones/Exhumaciones Getafe',
            'Inhumaciones/Exhumaciones Alcorcón',
            'Inhumaciones/Exhumaciones Pinto',
            'Lápidas Fuenlabrada',
            'Lápidas Getafe',
            'Lápidas Alcorcón',
            'Lápidas Pinto',
            'Adjudicaciones Torrelodones',
            'Inhumaciones/Exhumaciones Torrelodones',
            'Lápidas Torrelodones',
            'Adjudicaciones Fuenlabrada',
            'Prenecesidad Zentolen',
            'Post-Morten Zentolen',
            'Inhumaciones/Exhumaciones Zentolen',
            'Adjudicaciones Zentolen',
            'Lápidas Zentolen',
            'Destino final cementerios Landarri',
            'Adjudicaciones Colmenar Viejo',
            'Inhumaciones/Exhumaciones Colmenar Viejo',
            'Lápidas Colmenar Viejo',
            'Inhumaciones/Exhumaciones La Cabrera',
            'Inhumaciones/Exhumaciones Torrelaguna',
            'Lápidas Guadalix Sierra',
            'Inhumaciones/Exhumaciones Manzanares el Real',
            'Lápidas Manzanares el Real',
            'Lápidas Soto del Real',
            'Inhumaciones/Exhumaciones Velilla',
            'Lápidas Velilla',
            'Adjudicaciones Velilla',
            'Inhumaciones/Exhumaciones Boalo, Matalpino, Cerceda',
            'Inhumaciones/Exhumaciones El Espartal, El vellon',
            'Inhumaciones/Exhumaciones Guadalix Sierra',
            'Inhumaciones/Exhumaciones Hoyo de Manzanares',
            'Inhumaciones/Exhumaciones Mataelpino',
            'Inhumaciones/Exhumaciones Soto del Real',
            'Inhumaciones/Exhumaciones Talamanca del Jarama',
            'Inhumaciones/Exhumaciones Venturada',
            'Lápidas Boalo, Matalpino, Cerceda',
            'Lápidas Hoyo de Manzanares',
            'Lápidas Mataelpino',
            'Lápidas Torrelaguna'                
        }
    };

    // Creation of the "Servicio Compañias Servicio" aggrupation              
    public static List<String> SERVICIOS_COMPANIAS_SERVICO_AGRUPACION_LIST = new List<String>{
        'Regularizaciones'
    };

    /*Creation of the "Servicio Compañias Servicio" categories, its important to use the same agrupation name
	define previously at the moment of indicate the categories that should be inside*/      
    public static Map<String, List<String>> SERVICIOS_COMPANIAS_SERVICO_CATEGORIA_MAP = new Map<String, List<String>>{
        'Regularizaciones'=> new List<String>{//Add to Regularizaciones aggrupation the necesary categories
            'Regularizaciones'
        }
    };
}