(()=>{
'use strict';
const $=id=>document.getElementById(id), status=t=>$('authstatus').textContent=t;
const configured=!!(window.QUIMIQU_SUPABASE_URL&&window.QUIMIQU_SUPABASE_ANON_KEY&&window.supabase);
let db=configured?window.supabase.createClient(window.QUIMIQU_SUPABASE_URL,window.QUIMIQU_SUPABASE_ANON_KEY):null;
let user=null,profile=null,channel=null;
const labels={common:'COMÚN',member:'✦ MIEMBRO',boss:'♛ JEFE',admin:'★ ADMIN DE PÁGINA'};
function draw(m){
 $('empty-state')?.remove();
 const row=document.createElement('div');row.className='message';
 const avatar=document.createElement('div');avatar.className='avatar';avatar.textContent=(m.display_name||'?')[0].toUpperCase();
 const content=document.createElement('div');content.className='message-content';
 const by=document.createElement('div');by.className='by';
 const bold=document.createElement('b');bold.textContent=m.display_name||'Usuario';
 const badge=document.createElement('span');badge.className='badge '+(m.role||'common');badge.textContent=labels[m.role]||labels.common;
 const stamp=document.createElement('span');stamp.className='time';stamp.textContent=new Date(m.created_at).toLocaleTimeString('es-CL',{hour:'2-digit',minute:'2-digit'});
 by.append(bold,badge,stamp);const p=document.createElement('p');p.textContent=m.body;content.append(by,p);row.append(avatar,content);$('messages').append(row);$('messages').scrollTop=$('messages').scrollHeight;
}
async function loadMessages(){
 const {data,error}=await db.from('quimiqu_messages').select('id,body,created_at,display_name,role').order('created_at',{ascending:false}).limit(100);
 if(error){status(error.message);return}
 $('messages').replaceChildren();if(!data.length){const p=document.createElement('p');p.id='empty-state';p.textContent='Todavía no hay mensajes. ¡Escribe el primero!';$('messages').append(p)}
 data.reverse().forEach(draw);
}
async function refresh(){
 const {data:{user:u}}=await db.auth.getUser();user=u;
 $('guest').hidden=!!u;$('signed').hidden=!u;
 if(!u){profile=null;$('sendbutton').disabled=true;$('account').textContent='';return}
 const {data:p,error}=await db.from('quimiqu_profiles').select('display_name,role,user_number,handle').eq('id',u.id).maybeSingle();
 if(error){status(error.message);return}
 profile=p;
 $('account').textContent=u.email+' · @'+(p?.handle||'sin_identificador')+' · '+(labels[p?.role]||labels.common);
 $('name').value=p?.display_name||'';$('handle').value=p?.handle||'';
 $('sendbutton').disabled=!(p?.display_name&&p?.handle);
 status(p?.display_name&&p?.handle?'Sesión iniciada. Puedes participar.':'Guarda tu nombre y un identificador único antes de enviar mensajes.');
 await loadMessages();
}
if(!configured){status('Chat y registro pendientes de configurar: completa config.js con tu proyecto Supabase.');$('guest').querySelectorAll('input,button').forEach(el=>el.disabled=true);return}
$('authform').onsubmit=async e=>{e.preventDefault();const {error}=await db.auth.signInWithPassword({email:$('email').value.trim(),password:$('password').value});status(error?error.message:'Sesión iniciada');if(!error)await refresh()};
$('signup').onclick=async()=>{const email=$('email').value.trim(),password=$('password').value;if(!email||password.length<8){status('Introduce correo y contraseña de al menos 8 caracteres.');return}const {error}=await db.auth.signUp({email,password});status(error?error.message:'Cuenta creada. Revisa tu correo para confirmar el registro, si se requiere.')};
for(const provider of ['google','github','facebook'])$(provider).onclick=async()=>{const {error}=await db.auth.signInWithOAuth({provider,options:{redirectTo:new URL('chat.html',location.href).href}});if(error)status(error.message)};
$('logout').onclick=async()=>{await db.auth.signOut();await refresh()};
$('nameform').onsubmit=async e=>{e.preventDefault();if(!user)return;const name=$('name').value.trim(),handle=$('handle').value.trim();if(!/^[a-zA-Z0-9_]{3,24}$/.test(handle)){status('El identificador debe tener entre 3 y 24 caracteres: letras, números o _.');return}if(name.length<2||name.length>25){status('El nombre debe tener entre 2 y 25 caracteres.');return}const {error}=await db.from('quimiqu_profiles').update({display_name:name,handle}).eq('id',user.id);status(error?(error.code==='23505'?'Ese identificador ya está ocupado. Elige otro.':error.message):'Nombre e identificador guardados');if(!error)await refresh()};
$('sendform').onsubmit=async e=>{e.preventDefault();const msg=$('message').value.trim();if(!user||!(profile?.display_name&&profile?.handle)||!msg)return;const {error}=await db.from('quimiqu_messages').insert({user_id:user.id,body:msg});if(error){status(error.message);return}$('message').value='';await loadMessages()};
db.auth.onAuthStateChange(()=>setTimeout(refresh,0));
refresh();loadMessages();
channel=db.channel('quimiqu-chat').on('postgres_changes',{event:'INSERT',schema:'public',table:'quimiqu_messages'},()=>loadMessages()).subscribe();
})();