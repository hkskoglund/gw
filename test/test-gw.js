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
        wunderground : {
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

async function testIterate(f,maxIterations)
{
  for (let i =1; i<= maxIterations; i++) {
    console.log(`====== TEST ITERATION : ${i}`)
    await f();
  }
}

// https://codingwithspike.wordpress.com/2018/03/10/making-settimeout-an-async-await-function/
async function wait(ms) {
    return new Promise(resolve => {
      console.log('=== TEST TIMEOUT FOR '+ms + "ms");
      setTimeout(resolve, ms);
    });
  }

  async function testReadSystem()
  {
    let timerId = setInterval( async () =>  {
      await testIterate( async () => {  await gw.get(Command.READ_SYSTEM)},1);
     },1000);

     setTimeout(() => { clearTimeout(timerId)},8000);
     
     await testIterate( async () => { await gw.get(Command.READ_RAIN)},1);

  }

  function testPacketChecksum(epath,wupath)
  {
    var p = new Packet(Command.WRITE_USR_PATH);
    p.writeString(epath,wupath).writeCRC();
    console.log('==== TEST PACKET',p.getBuffer(),p.getChecksum())
  }

  async function main()
  {

    try {
      console.log('======================================== TEST START')
  
      await gw.connect('10.42.0.180');
      
      //await testIterate(testCustomized,1);
      //await testIterate( async () => { await gw.get(Command.READ_MAC)},1);
      //await testIterate( async () => { await gw.get(Command.READ_VER)},1);
      //await testIterate( async () => { await gw.get(Command.WRITE_REBOOT)},1);

     //await testReadSystem();

     testPacketChecksum('/testecowittpath','/testwupath');

  
    } catch (e)
    {
      console.log('===================== TEST CATCHED',e);
    }
  }

  await main();