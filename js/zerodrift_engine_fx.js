// zerodrift_engine_fx.js
export const FX_SHIFT = 32n;                 // Q32.32
export const FX_ONE = 1n << FX_SHIFT;

// Exact Q32 constants
export const HALF = FX_ONE >> 1n;            // 0.5
export const TWO = 2n * FX_ONE;              // 2.0
export const DT = FX_ONE / 60n;              // Exact 1/60 in Q32 (no rounding)

const K = 1n * FX_ONE;                       // spring constant (1.0)
const M = 1n * FX_ONE;                       // mass (1.0)

export function fx(n){ return BigInt(Math.floor(n * (2**Number(FX_SHIFT)))) }
export function toFloat(FX){ return Number(FX) / (2**Number(FX_SHIFT)) }
function fxAdd(a,b){ return a + b }
function fxSub(a,b){ return a - b }
function fxMul(a,b){ return (a*b) >> FX_SHIFT }
function fxDiv(a,b){ return (a << FX_SHIFT) / b }

export function seededRng(seed=123456789){
  let s = BigInt(seed) & ((1n<<64n)-1n);
  return ()=>{ s ^= s<<13n; s ^= s>>7n; s ^= s<<17n; return s & ((1n<<64n)-1n); }
}
export function rngFx01(r){ return (r() & ((1n<<32n)-1n)) } // 0..2^32-1
export function fxFromR(r){ return (rngFx01(r)) }           // already Q32 scale

export function buildTopology(N, mode="chain"){
  const edges=[];
  if(mode==="chain"){
    for(let i=0;i<N-1;i++) edges.push([i,i+1]);
  }else if(mode==="ring"){
    for(let i=0;i<N;i++) edges.push([i,(i+1)%N]);
  }else{ // "grid" (nearest neighbors on sqrt(N) grid)
    const S = Math.floor(Math.sqrt(N));
    for(let y=0;y<S;y++) for(let x=0;x<S;x++){
      const i = y*S+x;
      if(x+1<S) edges.push([i, i+1]);
      if(y+1<S) edges.push([i, i+S]);
    }
  }
  // canonicalize (sorted) to remove order nondeterminism
  return edges.map(([a,b])=> a<b?[a,b]:[b,a]).sort((A,B)=> (A[0]-B[0])||(A[1]-B[1]));
}

export function initState({N=64, seed=1337, span=0.25}={}){
  const rand = seededRng(seed);
  const x = new Array(N), p = new Array(N);
  for(let i=0;i<N;i++){
    // small random displacement and momentum in Q32.32
    const xf = (Number(rngFx01(rand)) / 2**32) * span - (span/2);
    const pf = (Number(rngFx01(rand)) / 2**32) * span - (span/2);
    x[i] = fx(xf);
    p[i] = fx(pf);
  }
  return { x, p, N };
}

function forces(state, edges){
  const f = new Array(state.N).fill(0n);
  for(const [a,b] of edges){
    const dx = fxSub(state.x[a], state.x[b]);
    // F = -k * (x_a - x_b) on a, opposite on b
    const f_ab = -fxMul(K, dx);
    f[a] = fxAdd(f[a], f_ab);
    f[b] = fxSub(f[b], f_ab);
  }
  return f;
}

// Symplectic Velocity-Verlet
export function stepSymplecticFx(state, dtFx, edges){
  const N = state.N;
  const f0 = forces(state, edges);
  // p(t+dt/2) = p(t) + 0.5*dt * f(t)
  for(let i=0;i<N;i++){ state.p[i] = fxAdd(state.p[i], fxMul(dtFx>>1n, f0[i])); }
  // x(t+dt) = x(t) + dt * p(t+dt/2)/m
  for(let i=0;i<N;i++){ state.x[i] = fxAdd(state.x[i], fxMul(dtFx, fxDiv(state.p[i], M))); }
  // p(t+dt) = p(t+dt/2) + 0.5*dt * f(t+dt)
  const f1 = forces(state, edges);
  for(let i=0;i<N;i++){ state.p[i] = fxAdd(state.p[i], fxMul(dtFx>>1n, f1[i])); }
}

export function computeH(state, edges){
  // Fixed Q32.32 math - no mixing scaled/unscaled constants
  const TWO_M = 2n * M;  // Q32: 2.0 * m
  
  // Kinetic: sum( (p^2) / (2 m) )
  let Ksum = 0n;
  for(let i=0;i<state.N;i++){
    const pp = fxMul(state.p[i], state.p[i]);  // Q32
    Ksum += fxDiv(pp, TWO_M);                  // Q32: (p^2)/(2m)
  }
  
  // Potential: sum( (k * dx^2) / 2 )
  let Psum = 0n;
  for(const [a,b] of edges){
    const dx = fxSub(state.x[a], state.x[b]);  // Q32
    const dx2 = fxMul(dx, dx);                  // Q32
    // Divide by 2 as Q32 value: denominator = 2.0 in Q32 = (2n*FX_ONE)
    Psum += fxDiv( fxMul(K, dx2), (2n*FX_ONE) );
  }
  
  return Ksum + Psum;  // Q32
}

export function morphTopology(mode, N){ return buildTopology(N, mode); }

// -------- baseline (float, naive Euler) for DRIFT DEMO ----------
export function stepBaselineFloat(stateF, dt, edges) {
  // stateF: { xf: Float64Array, pf: Float64Array, N }
  const f = new Float64Array(stateF.N);
  for(const [a,b] of edges){
    const dx = stateF.xf[a]-stateF.xf[b];
    const f_ab = -1.0 * dx;
    f[a]+=f_ab; f[b]-=f_ab;
  }
  for(let i=0;i<stateF.N;i++){
    stateF.pf[i] += dt * f[i];
    stateF.xf[i] += dt * (stateF.pf[i] / 1.0);
  }
}
export function computeHFloat(stateF, edges){
  let K=0, P=0;
  for(let i=0;i<stateF.N;i++){ K += 0.5*(stateF.pf[i]*stateF.pf[i]); }
  for(const [a,b] of edges){
    const dx = stateF.xf[a]-stateF.xf[b]; P += 0.5*(dx*dx);
  }
  return K+P;
}