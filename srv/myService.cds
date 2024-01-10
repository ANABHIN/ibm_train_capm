namespace ibmcapapp.srv;
using { anubhav.db.master as master } from '../db/datamodel';

service MyService {
    function helloWorld(spiderman : String(10), jumbo : String(10)) returns String(25);
    //   function helloWorld(spiderman : String(10), anand : String(10)) returns String(25);
    //   odata/v4/my/helloWorld(spiderman='amigo',jumbo='anand') : for testing multiple parameters
    function CalRad(radius : Int16)           returns Int16;

    @readonly
    entity ReadEmployeeSrv as projection on master.employees;
}
