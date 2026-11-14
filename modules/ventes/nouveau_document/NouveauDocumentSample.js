var clients = [
    {text: "SARL Atlas Distribution", value: 1, code: "CL-00101"},
    {text: "Société Horizon", value: 2, code: "CL-00102"}
];

var catalog = [
    {id: 42, reference: "ART-EL-042", description: "Câble Cuivre Isolé 2.5mm² (Rouleau 100m)", priceHT: 185, vat: 20},
    {id: 108, reference: "ART-IN-108", description: "Disjoncteur Modulaire 16A Phase+Neutre Schneider", priceHT: 45, vat: 20},
    {id: 215, reference: "ART-IN-215", description: "Boîte Dérivation Étanche IP65 150x110x70mm", priceHT: 28.5, vat: 20},
    {id: 33, reference: "ART-OT-033", description: "Gaine Cintrable ICTA Ø20 avec Tire-fil (100m)", priceHT: 132, vat: 20},
    {id: 9, reference: "ART-LG-009", description: "Prise de Courant 2P+T 16A Encastrable Blanche", priceHT: 19.5, vat: 20},
    {id: 14, reference: "ART-LG-014", description: "Interrupteur Simple Allumage Étanche Saillie", priceHT: 22, vat: 20},
    {id: 550, reference: "ART-CX-550", description: "Bornier de Raccordement 10 Entrées 4mm²", priceHT: 7.2, vat: 20}
];

var quantities = [10, 25, 15, 8, 40, 20, 50];
var lines = catalog.map(function(article, index) {
    var quantity = quantities[index];
    return {
        id: article.id,
        reference: article.reference,
        description: article.description,
        quantity: quantity,
        priceHT: article.priceHT,
        priceTTC: article.priceHT * 1.2,
        totalHT: article.priceHT * quantity,
        vat: article.vat,
        totalTTC: article.priceHT * quantity * 1.2
    };
});

var payments = [
    {id: 192, code: "REG-2025-0192", description: "Acompte à la commande par virement",
     amount: 3610.28, amountDisplay: "3 610,28 MAD", date: new Date(2025, 7, 14),
     dateDisplay: "14/08/2025", method: "Virement Bancaire"},
    {id: 193, code: "REG-2025-0193", description: "Solde convenu à livraison / Échéance 30j",
     amount: 3610.27, amountDisplay: "3 610,27 MAD", date: new Date(2025, 8, 14),
     dateDisplay: "14/09/2025", method: "Traite"}
];
