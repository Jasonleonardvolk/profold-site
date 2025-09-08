// proof-panel-live.js
(async function(){
  const elBar = document.getElementById('livebar');
  const elTxt = document.getElementById('live-text');
  
  // Dynamic API base - auto-switches between local dev and production
  const API_BASE = (location.hostname.endsWith('invariant.pro'))
    ? 'https://web-production-148bd.up.railway.app'  // Railway API live!
    : 'http://127.0.0.1:8008';
  
  const API = API_BASE;
  async function poll(){
    try{
      const r = await fetch(`${API}/api/proof/live/tip`, {cache:'no-store'});
      if(!r.ok) throw 0;
      const {step, sha_accum, verifiers} = await r.json();
      // Only show if verifiers > 0
      if(verifiers && verifiers > 0){
        elBar.classList.remove('hidden');
        elTxt.textContent = `LIVE VERIFIED ✓ · ${verifiers} verifiers · commit ${sha_accum.slice(0,8)}… · step ${step}`;
      } else {
        elBar.classList.add('hidden');
      }
    }catch{ 
      // Keep hidden on error
      elBar.classList.add('hidden');
    }
    setTimeout(poll, 1000);
  }
  poll();
})();