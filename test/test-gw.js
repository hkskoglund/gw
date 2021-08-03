import  GW from '../gw.js'
import  Packet from '../packet/packet.js'
import {Protocol,Command} from '../const.js'


let gw = new GW();


async function testCustomized()
{
     let backupCustomized = await gw.get(Command.READ_CUSTOMIZED);

     backupCustomized.path = await gw.get(Command.READ_USR_PATH);

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
        protocol : Protocol.ECOWITT
    }
    
        await gw.writeCustomized(customized);

       // console.log('=== TEST : WROTE CUSTOMIZED',customized)

        //await wait(30000);
        //customized.protocol = GW.Protocol.WUNDERGROUND;
        //await gw.writeCustomized(customized);
        //await wait(10000);
        /*
        gw.customized.enabled = false;
        await gw.writeCustomized();
        await wait(2000); */
        //customized = backupCustomized;
       
        await gw.writeCustomized(backupCustomized);
        //console.log('=== TEST : WROTE BACKUP CUSTOMIZED',backupCustomized);
        
}

async function testMAC()
{
  const mac = await gw.get(Command.READ_MAC);
}

async function testVersion()
{
  const version = await gw.get(Command.READ_VER);
}


async function testIterate(f,maxIterations)
{
  for (let i =0; i< maxIterations; i++)
    await f();
}

// https://codingwithspike.wordpress.com/2018/03/10/making-settimeout-an-async-await-function/
async function wait(ms) {
    return new Promise(resolve => {
      console.log('=== TEST TIMEOUT FOR '+ms + "ms");
      setTimeout(resolve, ms);
    });
  }

  try {
    console.log('======================================== TEST START')

    await gw.connect('10.42.0.180');
   // await testIterate(testCustomized,1);
    await testIterate(testMAC,10);
    await testIterate(testVersion,10);


  } catch (e)
  {
    console.log('Catched',e);
  }
