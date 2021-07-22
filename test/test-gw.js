import { GW } from '../gw.js'
import { Packet } from '../packet.js'

let gw = new GW();


async function testCustomized()
{
    gw.customized.enabled = true;
    gw.customized.upload_interval = 1;
    gw.customized.port = 8000;
    gw.customized.ecowitt.path = '/ecowitt';
    gw.customized.wunderground.path = '/wunderground'
    gw.customized.wunderground.id = 'id'
    gw.customized.wunderground.key = 'key';
    gw.customized.protocol = GW.Protocol.ECOWITT;
    await gw.writeCustomized();
    await wait(10000);
    gw.customized.protocol = GW.Protocol.WUNDERGROUND;
    await gw.writeCustomized();
    await wait(10000);
    gw.customized.enabled = false;
    await gw.writeCustomized();
    
}

// https://codingwithspike.wordpress.com/2018/03/10/making-settimeout-an-async-await-function/
async function wait(ms) {
    return new Promise(resolve => {
      setTimeout(resolve, ms);
    });
  }


await gw.connect('10.42.0.180');
await testCustomized();
