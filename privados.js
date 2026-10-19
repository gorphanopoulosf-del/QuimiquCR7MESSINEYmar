(()=>{
'use strict';
const $=id=>document.getElementById(id);
const url=window.QUIMIQU_SUPABASE_URL,key=window.QUIMIQU_SUPABASE_ANON_KEY;
if(!url||!key||!window.supabase)return;
const db=window.supabase.createClient(url,key);
let me=null,other=null,channel=null;
function state(t){$('private-with').textContent=t}
function reset(){other=null;$('private-messages').replaceChildren();$('private-text').disabled=true;$('private-send').disabled=true;$('private-open').disabled=!me}
function add(m){
 const p=document.createElement('p');p.style.cssText='padding:9px;border-bottom:1px solid #ffffff22;white-space:pre-wrap;overflow-wrap:anywhere';
 const who=document.createElement('b');who.textContent=m.sender_id===me?'Tú: ':'Otra persona: ';
 const msg=document.createTextNode(m.body);p.append(who,msg);$('private-messages').append(p);
 $('private-messages').scrollTop=$('private-messages').scrollHeight;
}
async function messages(){
 if(!me||!other)return;
 const filter=`and(sender_id.eq.${me},recipient_id.eq.${other}),and(sender_id.eq.${other},recipient_id.eq.${me})`;
 const {data,error}=await db.from('quimiqu_private_messages').select('id,sender_id,recipient_id,body,created_at').or(filter).order('created_at',{ascending:false}).limit(100);
 if(error){state('Error: '+error.message);return}
 $('private-messages').replaceChildren();
 if(!data.length){const p=document.createElement('p');p.textContent='Todavía no hay mensajes privados.';$('private-messages').append(p)}
 data.reverse().forEach(add);
}
async function users(){
 const {data,error}=await db.from('quimiqu_profiles').select('id,display_name,handle').not('display_name','is',null).not('handle','is',null).order('display_name');
 if(error){state('Error al cargar usuarios: '+error.message);return}
 const s=$('private-user');s.replaceChildren(new Option('Selecciona una persona',''));
 for(const p of data)if(p.id!==me)s.add(new Option(p.display_name+' · @'+(p.handle||'sin_identificador'),p.id));
}
async function refresh(){
 const {data:{user}}=await db.auth.getUser();const id=user?.id||null;
 if(me!==id){me=id;reset()}
 if(!me){state('Inicia sesión para usar los chats privados.');return}
 const {data:p}=await db.from('quimiqu_profiles').select('display_name').eq('id',me).maybeSingle();
 if(!p?.display_name||!p?.handle){state('Guarda tu nombre y tu identificador único antes de enviar mensajes privados.');$('private-open').disabled=true;return}
 $('private-open').disabled=false;await users();
 if(!other)state('Elige una persona para iniciar un chat privado.');
}
$('private-open').onclick=async()=>{
 const id=$('private-user').value;if(!id||!me||id===me)return;
 other=id;$('private-text').disabled=false;$('private-send').disabled=false;
 state('Chat privado con '+$('private-user').selectedOptions[0].textContent);
 await messages();
 if(channel)await db.removeChannel(channel);
 channel=db.channel('quimiqu-private-'+me+'-'+other).on('postgres_changes',{event:'INSERT',schema:'public',table:'quimiqu_private_messages'},payload=>{
 if((payload.new.sender_id===me&&payload.new.recipient_id===other)||(payload.new.sender_id===other&&payload.new.recipient_id===me))messages();
 }).subscribe();
};
$('private-form').onsubmit=async e=>{
 e.preventDefault();if(!me||!other)return;
 const body=$('private-text').value.trim();if(!body)return;
 const {error}=await db.from('quimiqu_private_messages').insert({sender_id:me,recipient_id:other,body});
 if(error){state('No se pudo enviar: '+error.message);return}
 $('private-text').value='';await messages();
};
db.auth.onAuthStateChange(()=>setTimeout(refresh,0));
refresh();
})();