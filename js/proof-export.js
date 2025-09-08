// proof-export.js
export function exportProofJSON(obj){
  const blob = new Blob([JSON.stringify(obj,null,2)], {type:'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `proof_receipt_${new Date().toISOString().replace(/[:.]/g,'-')}.json`;
  document.body.appendChild(a); a.click(); a.remove();
}