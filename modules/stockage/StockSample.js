.pragma library

var documents = [
    { id: 1, code: "STK-2025-001", type: "Entrée de stock", typeVariant: "success", date: "10/01/2025", status: "Validé", statusVariant: "success", comment: "Réception fournisseur Atlas Tech" },
    { id: 2, code: "STK-2025-002", type: "Sortie de stock", typeVariant: "warning", date: "12/01/2025", status: "Brouillon", statusVariant: "warning", comment: "Préparation commande client" },
    { id: 3, code: "STK-2025-003", type: "Ajustement", typeVariant: "info", date: "14/01/2025", status: "Validé", statusVariant: "success", comment: "Contrôle de stock" },
    { id: 4, code: "STK-2025-004", type: "Inventaire", typeVariant: "neutral", date: "17/01/2025", status: "En attente", statusVariant: "warning", comment: "Inventaire mensuel" }
];

var lines = [
    { id: 1, reference: "ART-1042", description: "Câble réseau Cat6A blindé 305m", quantity: "25,00", comment: "Lot #2025-A • Allée B2" },
    { id: 2, reference: "ART-2089", description: "Switch Gigabit Manageable 24 ports PoE+", quantity: "8,00", comment: "Réception fournisseur Atlas Tech" },
    { id: 3, reference: "ART-3310", description: "Panneau de brassage 24 ports RJ45", quantity: "12,00", comment: "Contrôle qualité validé" },
    { id: 4, reference: "ART-4105", description: "Onduleur Rack 1500VA / 1050W", quantity: "4,00", comment: "Zone sécurisée Z1" },
    { id: 5, reference: "ART-5021", description: "Connecteurs RJ45 Blindés (Boîte de 100)", quantity: "50,00", comment: "Stock tampon" }
];

var articles = lines.map(function (line) { return { reference: line.reference, description: line.description }; });
