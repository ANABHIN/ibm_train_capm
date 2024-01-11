namespace ibmcapapp.srv;

using {
    anubhav.db.master as master,
    anubhav.db.transaction as transaction
} from '../db/datamodel';

using {cappo.cds as cds} from '../db/CDSViews';

//test git change
// service CatalogService @(path: 'CatalogService') {
//     @readonly // if we want to restrict editing
//     entity EmployeeSet        as projection on master.employees;

//     @Capabilities: {
//         Updatable: false,
//         Deletable: false
//     }
//     entity BusinessPartnerSet as projection on master.businesspartner;

//     // entity ProductSet         as projection on master.product;
//     entity POs                as projection on transaction.purchaseorder;
//     entity POItems            as projection on transaction.poitems;
//     entity ProductView as projection on cds.CDSViews.;
// }

service CatalogService @(
    path    : 'CatalogService',
    requires: 'authenticated-user'
) {
    //End point to perform CURDQ operation - Create, Update, Read, Delete, Query
    // @readonly
    entity EmployeeSet     @(
        restrict:[
            {grant: ['READ'], to: 'Viewer', where : 'bankName = $user.BankName'},
            {grant: ['WRITE'], to: 'Admin'}
        ]
    )       as projection on master.employees;

    @Capabilities: {
        Updatable: false,
        Deletable: false
    }
    entity BusinessPartnerSet               as projection on master.businesspartner;

    entity ProductSet                       as projection on master.product;

    // entity POs                as
    //     projection on transaction.purchaseorder {
    //         *,
    //         Items
    //     } actions {
    //         action   boost();
    //         function largestOrder() returns array of POs;
    //     };

    entity POs @(odata.draft.enabled: true) as
        projection on transaction.purchaseorder {
            *,
            round(GROSS_AMOUNT) as GROSS_AMOUNT  : Decimal(10, 2),
            case OVERALL_STATUS
                when
                    'N'
                then
                    'New'
                when
                    'P'
                then
                    'Pending'
                when
                    'D'
                then
                    'Delivered'
                when
                    'A'
                then
                    'Approved'
                when
                    'X'
                then
                    'Rejected'
            end                 as OverallStatus : String(10),
            case OVERALL_STATUS
                when
                    'N'
                then
                    2
                when
                    'P'
                then
                    2
                when
                    'D'
                then
                    3
                when
                    'A'
                then
                    3
                when
                    'X'
                then
                    1
            end                 as Criticality   : Integer,

            Items                                : redirected to POItems
        } actions {
            //definition
            @cds.odata.bindingparameter.name: '_anubhav'
            @Common.SideEffects             : {TargetProperties: ['_anubhav/GROSS_AMOUNT']}
            action   boost();
            function largestOrder() returns array of POs;
        };

    entity POItems                          as projection on transaction.poitems;

//Commented for removing View test
// entity ProductView as projection on cds.CDSViews.ProductView{
//     *,
//     To_Items
// };
// entity POItems as projection on cds.CDSViews.ItemVie
// entity ProductView        as
//     projection on cds.CDSViews.ProductView {
//         *,
//         To_Items
//     };

// entity POItems            as projection on cds.CDSViews.ItemView;
}
