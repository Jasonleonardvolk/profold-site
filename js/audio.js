// audio.js
let ctx=null, osc=null, gain=null;
export function audioStart(){
  if(ctx) return true;
  try{
    ctx = new (window.AudioContext||window.webkitAudioContext)();
    osc = ctx.createOscillator(); gain = ctx.createGain();
    osc.type='sine'; osc.frequency.value=440; gain.gain.value=0.0;
    osc.connect(gain).connect(ctx.destination); osc.start();
    return true;
  }catch{ return false; }
}
export function audioStop(){ try{ if(gain) gain.gain.value=0.0; }catch{} }
export function audioSet(freq, vol=0.06){
  if(!osc||!gain) return;
  osc.frequency.setTargetAtTime(freq, ctx.currentTime, 0.02);
  gain.gain.setTargetAtTime(vol, ctx.currentTime, 0.05);
}