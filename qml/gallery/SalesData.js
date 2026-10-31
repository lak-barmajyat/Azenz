.pragma library
var columns = [
    {key:"clientCode",title:"Code Client",type:"code",width:116},
    {key:"client",title:"Client",width:276},
    {key:"documentCode",title:"Code Doc",type:"code",width:144},
    {key:"documentType",title:"Type de doc",type:"status",width:118},
    {key:"date",title:"Date",type:"date",width:106},
    {key:"ht",title:"Total HT",type:"currency",alignment:"right",width:118},
    {key:"vat",title:"TVA",type:"currency",alignment:"right",width:106},
    {key:"ttc",title:"Total TTC",type:"currency",alignment:"right",width:128}
];
var rows = [
    {id:1,clientCode:"CLI-00109",client:"SARL ATLAS DISTRIBUTION",documentCode:"DV-2025-0042",documentType:"Devis",statusVariant:"neutral",date:"08/10/2026",ht:14250,vat:2850,ttc:17100},
    {id:2,clientCode:"CLI-00142",client:"ATLAS LOGISTICS TRANSIT S.A.",documentCode:"BC-2025-0018",documentType:"Commande",statusVariant:"info",date:"07/10/2026",ht:48200,vat:9640,ttc:57840},
    {id:3,clientCode:"CLI-00215",client:"COMPTOIR ATLAS DE MATÉRIAUX",documentCode:"FA-2025-0105",documentType:"Facture",statusVariant:"success",date:"06/10/2026",ht:124500,vat:24900,ttc:149400},
    {id:4,clientCode:"CLI-00244",client:"MAROC TRANSIT EXPRESS",documentCode:"FC-2025-1109",documentType:"Facture",statusVariant:"success",date:"05/10/2026",ht:210000,vat:42000,ttc:252000},
    {id:5,clientCode:"CLI-00055",client:"ATLAS MINING INDUSTRIE",documentCode:"DV-2025-0038",documentType:"Annulé",statusVariant:"danger",date:"02/10/2026",ht:15600,vat:3120,ttc:18720},
    {id:6,clientCode:"CLI-00087",client:"SOCIETE INDUSTRIELLE DU NORD",documentCode:"BC-2025-0982",documentType:"Commande",statusVariant:"info",date:"01/10/2026",ht:65000,vat:13000,ttc:78000},
    {id:7,clientCode:"CLI-00312",client:"GLOBAL LOGISTICS TANGER",documentCode:"DV-2025-0044",documentType:"Devis",statusVariant:"neutral",date:"29/09/2026",ht:31400,vat:6280,ttc:37680}
];
