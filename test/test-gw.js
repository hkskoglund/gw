import  GW from '../gw.js'
import  Packet from '../packet/packet.js'

let gw = new GW();


async function testCustomized()
{
     let backupCustomized = await gw.get(GW.Command.READ_CUSTOMIZED);

     backupCustomized.path = await gw.get(GW.Command.READ_USR_PATH);

    let customized = {
        enabled : false,
        interval : 1,
        hostname : '10.42.0.4',
        port : 9000,
         path : {
          ecowitt : '/ecowitt/test/test2',
          wunderground : '/wunderground/test/test2'
        },
        //ecowitt : {
       //     path : '/ecowitt/test'
       // },
        wunderground : {
   //         path : '/wunderground/test',
            id : 'idtestidtest2',
            key : 'keytestkeytest2'
        },
        protocol : GW.Protocol.ECOWITT
    }
    
        await gw.writeCustomized(customized);

        console.log('=== TEST : WROTE CUSTOMIZED',customized)

        await wait(30000);
        //customized.protocol = GW.Protocol.WUNDERGROUND;
        //await gw.writeCustomized(customized);
        //await wait(10000);
        /*
        gw.customized.enabled = false;
        await gw.writeCustomized();
        await wait(2000); */
        //customized = backupCustomized;
       
        await gw.writeCustomized(backupCustomized);
        console.log('=== TEST : WROTE BACKUP CUSTOMIZED',backupCustomized);
        
}

// https://codingwithspike.wordpress.com/2018/03/10/making-settimeout-an-async-await-function/
async function wait(ms) {
    return new Promise(resolve => {
      console.log('=== TEST TIMEOUT FOR '+ms + "ms");
      setTimeout(resolve, ms);
    });
  }

  try {
    console.log('=== TEST START')

    await gw.connect('10.42.0.180');
    await testCustomized();
  } catch (e)
  {
    console.log('Catched',e);
  }
