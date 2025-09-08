// topology_viz.js
export function drawTopologyChord(ctx, w, h, edges, N){
  ctx.clearRect(0,0,w,h);
  const R = Math.min(w,h)*0.42, cx=w/2, cy=h/2;
  const pos = Array.from({length:N}, (_,i)=>{
    const a = (i/N)*2*Math.PI - Math.PI/2;
    return [cx + R*Math.cos(a), cy + R*Math.sin(a)];
  });
  ctx.lineWidth = 1.0; ctx.strokeStyle = '#49526833';
  for(const [a,b] of edges){
    const [x1,y1]=pos[a], [x2,y2]=pos[b];
    ctx.beginPath();
    ctx.moveTo(x1,y1);
    const mx=(x1+x2)/2, my=(y1+y2)/2, k=0.18;
    ctx.quadraticCurveTo(mx+(cy-my)*k, my+(mx-cx)*k, x2,y2);
    ctx.stroke();
  }
  // nodes
  ctx.fillStyle='#9aa3b2';
  for(const [x,y] of pos){ ctx.beginPath(); ctx.arc(x,y,2,0,2*Math.PI); ctx.fill(); }
}