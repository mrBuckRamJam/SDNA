; =============================================================================
; 4K INTRO: SDNA - an hypnotic organic cell journey 
; Coded by: Mr.Buck Ram Jam - 09/05/2026 - 12:55
; Toolkits: NASM + CRINKLER + 4kLANG
; =============================================================================

bits 32

extern _PeekMessageA@20, _DispatchMessageA@4
; Importazioni API Windows
extern _CreateWindowExA@48, _GetDC@4, _ChoosePixelFormat@8, _SetPixelFormat@12
extern _wglCreateContext@4, _wglMakeCurrent@8, _SwapBuffers@4, _ExitProcess@4, _GetClientRect@8, _ShowWindow@8, _SetWindowLongA@12, _SetWindowPos@28, _GetSystemMetrics@4, _SetProcessDPIAware@0
extern _timeBeginPeriod@4, _Sleep@4, _GetAsyncKeyState@4, _wglGetProcAddress@4, _glRecti@16, _glViewport@16, _timeGetTime@0
extern _glEnable@4, _glDisable@4
extern _waveOutOpen@24, _waveOutPrepareHeader@12, _waveOutWrite@12
extern _4klang_render@4

%include "4klang.inc"

section .data
    align 4
    ; Formato audio: Stereo, 44100Hz, 32-bit Float (IEEE)
    wave_fmt:
        dw 3            ; wFormatTag (WAVE_FORMAT_IEEE_FLOAT)
        dw 2            ; nChannels (Stereo)
        dd 44100        ; nSamplesPerSec
        dd 44100*8      ; nAvgBytesPerSec (44100 * 2 ch * 4 bytes)
        dw 8            ; nBlockAlign
        dw 32           ; wBitsPerSample
        dw 0            ; cbSize

    wave_hdr:
        dd sound_buffer ; lpData
        dd MAX_SAMPLES*8; dwBufferLength
        dd 0, 0, 12, -1, 0, 0 ; Flags=12 (BEGIN+END loop), Loops=-1 (infinito)

    ; PFD rigorosamente 40 byte per driver Intel
    pfd dw 40, 1        ; nSize, nVersion
        dd 0x25         ; dwFlags (DOUBLEBUFFER | SUPPORT_OPENGL | DRAW_TO_WINDOW)
        db 0, 32        ; iPixelType, cColorBits
        times 13 db 0   ; cRedBits... cAccumAlphaBits
        db 24, 8, 0     ; cDepthBits, cStencilBits, cAuxBuffers
        db 0, 0         ; iLayerType, bReserved
        dd 0, 0, 0      ; dwLayerMask...

    wcls db "edit", 0 
    s_glCS  db "glCreateShader", 0
    s_glSS  db "glShaderSource", 0
    s_glCO  db "glCompileShader", 0
    s_glCP  db "glCreateProgram", 0
    s_glAS  db "glAttachShader", 0
    s_glLP  db "glLinkProgram", 0
    s_glUP  db "glUseProgram", 0
    s_glGUL db "glGetUniformLocation", 0
    s_glU1F db "glUniform1f", 0
    s_glU2F db "glUniform2f", 0
    s_time  db "t", 0
    s_res   db "r", 0
    f1000   dd 0.001

    ; --- FORZA GPU ALTE PRESTAZIONI ---
    ; Esportiamo queste variabili in modo che i driver le vedano nell'header dell'EXE
    global NvOptimusEnablement
    global AmdPowerXpressRequestHighPerformance
    NvOptimusEnablement dd 0x00000001
    AmdPowerXpressRequestHighPerformance dd 0x00000001

    ; --- SHADER SOURCE: COMPLEX ORGANIC TUNNEL ---
    shader_src:
    db "#version 120", 10, "uniform float t;uniform vec2 r;float m_id;vec3 RD;", 10
    db "float h(vec3 p){p=fract(p*0.1031);p+=dot(p,p.yzx+33.33);return fract((p.x+p.y)*p.z);}", 10
    db "float smin(float a,float b,float k){float h=max(k-abs(a-b),0.)/k;return min(a,b)-h*h*k*.25;}", 10
    db "float d(vec3 p){float mt=mod(t,134.),tm=p.z+mt*1.5;m_id=0.;vec2 offs=vec2(sin(tm*.4),cos(tm*.3))*.8;", 10
    db "float sk=smoothstep(50.,75.,mt),rev=step(80.,mt)*step(mt,105.),fin=smoothstep(105.,134.,mt),pulse=sin(t*8.)*.5+.5;", 10
    db "float rad=mix(2.5,35.,sk);float tu=rad-length(p.xy+offs);tu-=(cos(p.x*.3)*cos(p.y*.3)*cos(p.z*.2))*(1.+sk*4.0);", 10
    db "vec2 g=abs(mod(p.xy+offs,4.2))-2.1;float f=length(g)-.15;if(sk>.5)f=min(f,length(abs(mod(p.xy+offs+vec2(sin(p.z*.5),cos(p.z*.5)),5.))-2.5)-.02);if(f<tu)tu=f;", 10
    db "float hz=mix(15.,3.2,fin);vec3 hp=vec3(p.xy+offs,p.z-hz);", 10
    db "vec3 qd=hp;float ay=t*.3,cf=cos(ay),sf=sin(ay);qd.xy*=mat2(cf,sf,-sf,cf);", 10
    db "float tw=qd.z*5.;vec2 ps=vec2(cos(tw),sin(tw))*.15;float dS=min(length(qd.xy-ps),length(qd.xy+ps))-.015;", 10
    db "float rz=floor(qd.z/.4+.5)*.4;vec3 p1=vec3(cos(rz*5.)*.15,sin(rz*5.)*.15,rz);", 10
    db "#define L(A,B) length(qd-A-(B-A)*clamp(dot(qd-A,B-A)/dot(B-A,B-A),0.,1.))", 10
    db "float dna=min(dS,min(L(p1,-p1)-.01,min(length(qd-p1),length(qd+p1))-.035));float dna_g=dna;float h_sz=2.8;", 10
    db "vec3 qh=hp;qh.x+=qh.y*0.35;float v1=length((qh+vec3(0.,0.7,0.))*vec3(1.1,1.,1.1)),v2=length((qh-vec3(0.8,0.2,0.2))*vec3(1.3,1.1,1.2)),v3=length((qh-vec3(-0.2,1.3,0.3))*vec3(1.,2.1,1.3)),v4=length((qh-vec3(0.7,1.2,0.1))*vec3(1.2,1.9,1.4));", 10
    db "float hrt=min(min(v1,v2),min(v3,v4))-h_sz*(1.+pulse*.15);", 10
    db "float beat=step(0.7,pulse);if(sk>0.01){if(rev>.5){float sd=abs(hrt)-.02;if(dot(hp,RD)<-2.2)sd=99.;float d_o=min(dna_g,sd);if(d_o<tu){tu=d_o;m_id=dna_g<sd?6.:7.;}}else{float h_p=hrt+(rev*beat)*100.0,f_p=dna_g+100.0;if(h_p<tu){tu=h_p;m_id=5.0;}if(f_p<tu){tu=f_p;m_id=6.0;}}}", 10
    db "if(rev<0.5){vec3 pv=p;pv.z+=mt*.5;vec3 pi=floor(pv/1.2),pg=mod(pv,1.2)-.6;pg+=(vec3(h(pi),h(pi+1.1),h(pi+2.2))-.5)*0.8;float part=length(pg)-.008;if(part<tu){tu=part;m_id=4.0;}", 10
    db "float sid=floor(tm/8.);vec3 cr=vec3(p.xy+offs,mod(tm,8.)-4.);for(int i=0;i<12;i++){float ra=h(vec3(float(i),sid,1.)),rb=h(vec3(float(i),sid,2.)),rc=h(vec3(float(i),sid,3.));", 10
    db "vec3 o=vec3(cos(ra*6.3),sin(ra*6.3),0.)*(rb*mix(1.7,30.0,sk));o.z=float(i)*1.1-4.2+rc*0.3;vec3 rp=cr+o;float rt=t*(0.4+ra*2.)+rb*9.,s=sin(rt),c=cos(rt);float d_o,m_o;", 10
    db "if(ra<0.65){rp.xy*=mat2(c,s,-s,c);rp.yz*=mat2(c,s,-s,c);float sz=0.35+rb*0.1;d_o=length(rp*vec3(1,1,2.1))-sz;d_o+=pow(max(0.,sz-length(rp.xy*1.5)),2.5);m_o=1.0;}", 10
    db "else if(ra<0.85){rp.xz*=mat2(c,s,-s,c);rp.yx*=mat2(c,s,-s,c);d_o=length(rp)-(0.2+rb*0.1)+(cos(rp.x*18.)*cos(rp.y*18.)*cos(rp.z*18.))*0.06;m_o=2.0;}", 10
    db "else{rp.xy*=mat2(c,s,-s,c);d_o=length(rp*vec3(2,2,1))-(0.16+rb*0.1)-abs(sin(atan(rp.y,rp.x)*5.))*0.1;m_o=3.0;}if(d_o<tu){tu=d_o;m_id=m_o;}}}return tu*0.3;}", 10
    db "vec3 gn(vec3 p){vec2 e=vec2(.001,0.);return normalize(vec3(d(p+e.xyy)-d(p-e.xyy),d(p+e.yxy)-d(p-e.yxy),d(p+e.yyx)-d(p-e.yyx)));}", 10
    db "float ao(vec3 p,vec3 n){float s=1.,o=0.;for(int i=1;i<5;i++){float d2=float(i)*.15;o+=(d2-d(p+n*d2))*s;s*=.5;}return clamp(1.-o,0.,1.);}", 10
    db "float C(vec2 p,float n,float rv){vec2 i=floor(p*vec2(3,5)),f=fract(p*vec2(3,5));i.x=2.-i.x;float b=i.x+i.y*3.;if(i.x<0.||i.x>2.||i.y<0.||i.y>4.||b>rv*15.)return 0.;float bit=floor(mod(n*exp2(-b),2.));return bit*max(step(abs(f.x-.5),.42),step(abs(f.y-.5),.42));}", 10
    db "void main(){vec2 uv=(gl_FragCoord.xy-r*0.5)/r.y;float mt=mod(t,134.),sk=smoothstep(50.,75.,mt),yel=step(75.,mt)*step(mt,80.),rev=step(80.,mt)*step(mt,105.),fin=smoothstep(105.,134.,mt),end=smoothstep(5.0,0.0,mt),pulse=sin(t*8.)*.5+.5,beat=step(0.7,pulse),p_s=pow(pulse,8.)*sk;", 10
    db "vec3 ro=vec3(sin(t*100.),cos(t*110.),0.)*p_s*.1;RD=normalize(vec3(uv,1.1));vec3 p;float tr=0.,m;for(int i=0;i<128;i++){p=ro+RD*tr;m=d(p);tr+=m;if(m<.001||tr>130.)break;}", 10
    db "float obj=m_id,hz=mix(15.,3.2,fin);vec3 n=gn(p),l=normalize(vec3(1,1,-1));float df=max(dot(n,l),0.),a=ao(p,n),ss=clamp(d(p+l*.4)/.4,0.,1.),dL=length(vec3(p.xy+vec2(sin((p.z+mt*1.5)*.4),cos((p.z+mt*1.5)*.3))*.8,p.z-hz));", 10
    db "float fr=pow(1.-max(dot(n,-RD),0.),3.);vec3 c=mix(vec3(.4,.05,.05),vec3(.1,0,0),n.y*.5+.5);if(obj==1.)c=vec3(1,0,0);else if(obj==2.)c=vec3(.9,.9,1);else if(obj==3.)c=vec3(.9,.8,.5);", 10
    db "else if(obj==4.)c=mix(vec3(.5,.8,1),vec3(.1,0,0),.6);else if(obj==5.){float fv=dL-(1.3+pulse*.5);c=mix(vec3(1,.4,.2)*a,vec3(.3,.01,.01),clamp(fv,0.,1.));if(yel>0.5)c=mix(c,vec3(1,.8,0),pulse);}else if(obj==6.)c=vec3(.05,.75,1.);else if(obj==7.)c=vec3(2.0,2.0,3.0);", 10
    db "vec3 cl=c*df*a+vec3(.8,.2,.1)*ss*.8+a*.25+fr*vec3(1,.8,.7)*.4+vec3(1,.8,.2)*p_s/(1.+dL*dL*.05);", 10
    db "if(rev>0.5){if(obj!=6.)cl=vec3(dot(cl,vec3(.3)));cl+=(h(vec3(gl_FragCoord.xy,t))-.5)*.15;cl+=step(abs(uv.y-fract(t*.5)*2.+1.),.005)*.15;", 10
    db "float nc=floor((mt-80.)*1.27)-2.,rv=fract((mt-80.)*1.27),s=0.;vec2 q=uv*10.,qb=uv*16.;", 10
    db "#define _R 31725.", 10
    db "#define _A 11245.", 10
    db "#define _M 24429.", 10
    db "#define _J 4714.", 10
    db "#define _S 31183.", 10
    db "#define _C 31015.", 10
    db "#define _E 30951.", 10
    db "#define _N 24573.", 10
    db "#define _D 27502.", 10
    db "if(nc>=0.){s+=C(q-vec2(-3.5,3.5),_R,nc==0.?rv:1.);s+=C(qb-vec2(-5.0,-5.5),_S,nc==0.?rv:1.);}if(nc>=1.){s+=C(q-vec2(-2.3,3.5),_A,nc==1.?rv:1.);s+=C(qb-vec2(-3.8,-5.5),_C,nc==1.?rv:1.);}", 10
    db "if(nc>=2.){s+=C(q-vec2(-1.1,3.5),_M,nc==2.?rv:1.);s+=C(qb-vec2(-2.6,-5.5),_E,nc==2.?rv:1.);}if(nc>=3.)s+=C(qb-vec2(-1.4,-5.5),_N,nc==3.?rv:1.);", 10
    db "if(nc>=4.){s+=C(q-vec2(0.9,3.5),_J,nc==4.?rv:1.);s+=C(qb-vec2(-0.2,-5.5),_E,nc==4.?rv:1.);}if(nc>=5.){s+=C(q-vec2(2.1,3.5),_A,nc==5.?rv:1.);s+=C(qb-vec2(1.0,-5.5),_R,nc==5.?rv:1.);}", 10
    db "if(nc>=6.){s+=C(q-vec2(3.3,3.5),_M,nc==6.?rv:1.);}if(nc>=7.)s+=C(qb-vec2(3.0,-5.5),_D,nc==7.?rv:1.);if(nc>=8.)s+=C(qb-vec2(4.2,-5.5),_N,nc==8.?rv:1.);if(nc>=9.)s+=C(qb-vec2(5.4,-5.5),_A,nc==9.?rv:1.);", 10
    db "cl=mix(cl,mix(vec3(2.),vec3(2.,0.,0.),pulse),step(.1,s));}", 10
    db "vec3 fc=mix(cl,mix(vec3(.02,.002,.002),vec3(.01),rev),clamp(tr*.001,0.,1.));", 10
    db "gl_FragColor=vec4(mix(pow(fc,vec3(.45)),vec3(1.),end)*min(1.,(402.-t)*.2),1.);}", 0

section .bss
    hDC_gl resd 1
    prog   resd 1
    loc_t  resd 1
    loc_r  resd 1
    f_glCS  resd 1
    f_glSS  resd 1
    f_glCO  resd 1
    f_glCP  resd 1
    f_glAS  resd 1
    f_glLP  resd 1
    f_glUP  resd 1
    f_glGUL resd 1
    f_glU1F resd 1
    f_glU2F resd 1
    shader_ptr_array resd 1
    msg    resb 28
    hWnd   resd 1
    rect   resd 4
    align 4
    is_windowed resd 1
    start_time resd 1
    wave_handle resd 1
    align 4
    screen_w resd 1
    screen_h resd 1
    sound_buffer resb MAX_SAMPLES * 8 ; Buffer per l'audio renderizzato

section .text

global _main
_main:
    ; --- FIX MULTIMONITOR/HIGH-DPI ---
    call _SetProcessDPIAware@0  ; Forza Windows a usare i pixel reali invece di quelli scalati

    push 1                      ; Imposta risoluzione timer a 1ms
    call _timeBeginPeriod@4

    ; --- DEBUG: Togli il '
    ;' sotto per far capire alla logica F11 che parti in finestra
    ; mov dword [is_windowed], 1

    ; --- RENDERING AUDIO ---
    push sound_buffer
    call _4klang_render@4

    ; --- APERTURA DISPOSITIVO AUDIO ---
    push 0              ; dwFlags
    push 0              ; dwCallback
    push 0              ; dwInstance
    push wave_fmt       ; lpFormat
    push -1             ; uDeviceID (WAVE_MAPPER)
    push wave_handle    ; phwo
    call _waveOutOpen@24

    ; --- PREPARAZIONE E INVIO BUFFER ---
    push 32             ; cbwh (sizeof WAVEHDR)
    push wave_hdr       ; lpwh
    push dword [wave_handle]
    call _waveOutPrepareHeader@12

    push 32
    push wave_hdr
    push dword [wave_handle]
    call _waveOutWrite@12

    ; --- OTTENIMENTO RISOLUZIONE SCHERMO PRIMARIO ---
    push 0                      ; SM_CXSCREEN (Risoluzione orizzontale monitor primario)
    call _GetSystemMetrics@4
    mov [screen_w], eax
    push 1                      ; SM_CYSCREEN (Risoluzione verticale monitor primario)
    call _GetSystemMetrics@4
    mov [screen_h], eax

    ; --- CREAZIONE FINESTRA ---
    push 0
    push 0
    push 0
    push 0
    push 0                  ; hWndParent
    push dword [screen_h]   ; nHeight (Usa la risoluzione reale invece di 0)
    push dword [screen_w]   ; nWidth  (Usa la risoluzione reale invece di 0)
    push 0                  ; y
    push 0                  ; x
    push 0x90000000         ; dwStyle (WS_POPUP | WS_VISIBLE)
    ; Config B: Finestra (Debug)
     ;push 360              ; nHeight
     ;push 480              ; nWidth
     ;push 100              ; y
     ;push 100              ; x
     ;push 0x10CF0000       ; dwStyle (Windowed)

    push 0
    push wcls
    push 0
    call _CreateWindowExA@48
    mov [hWnd], eax
    push eax
    call _GetDC@4
    mov [hDC_gl], eax

    push pfd
    push eax
    call _ChoosePixelFormat@8

    push pfd
    push eax
    push dword [hDC_gl]
    call _SetPixelFormat@12

    push dword [hDC_gl]
    call _wglCreateContext@4

    push eax
    push dword [hDC_gl]
    call _wglMakeCurrent@8

    ; --- RISOLUZIONE EXTENSIONS ---
    push s_glCS
    call _wglGetProcAddress@4
    mov [f_glCS], eax

    push s_glSS
    call _wglGetProcAddress@4
    mov [f_glSS], eax

    push s_glCO
    call _wglGetProcAddress@4
    mov [f_glCO], eax

    push s_glCP
    call _wglGetProcAddress@4
    mov [f_glCP], eax

    push s_glAS
    call _wglGetProcAddress@4
    mov [f_glAS], eax

    push s_glLP
    call _wglGetProcAddress@4
    mov [f_glLP], eax

    push s_glUP
    call _wglGetProcAddress@4
    mov [f_glUP], eax

    push s_glGUL
    call _wglGetProcAddress@4
    mov [f_glGUL], eax

    push s_glU1F
    call _wglGetProcAddress@4
    mov [f_glU1F], eax

    push s_glU2F
    call _wglGetProcAddress@4
    mov [f_glU2F], eax

    ; --- COMPILAZIONE SHADER ---
    push 0x8B30 ; GL_FRAGMENT_SHADER
    call [f_glCS]
    mov edi, eax ; edi = shader handle

    mov dword [shader_ptr_array], shader_src
    push 0
    push shader_ptr_array
    push 1
    push edi
    call [f_glSS]

    push edi
    call [f_glCO]

    call [f_glCP]
    mov [prog], eax

    push edi
    push eax
    call [f_glAS]

    push dword [prog]
    call [f_glLP]

    ; --- CACHING UNIFORM LOCATIONS (Migliora drasticamente le performance) ---
    push s_time
    push dword [prog]
    call [f_glGUL]
    mov [loc_t], eax
    push s_res
    push dword [prog]
    call [f_glGUL]
    mov [loc_r], eax

    call _timeGetTime@0
    mov [start_time], eax

.r_loop:
    ; --- ESCAPE CHECK ---
    push 27 ; VK_ESCAPE
    call _GetAsyncKeyState@4
    test ah, 0x80
    jnz .exit

    ; --- MESSAGE PUMP (Soddisfa Windows e previene il blocco) ---
    push 1                      ; PM_REMOVE
    push 0                      ; hWnd (tutte le finestre del thread)
    push 0                      ; wMsgFilterMin
    push 0                      ; wMsgFilterMax
    push msg                    ; lpMsg (usiamo il buffer in .bss)
    call _PeekMessageA@20
    test eax, eax
    jz .draw                    ; Se non ci sono messaggi, renderizza

    cmp dword [msg + 4], 0x10   ; Verifica se il messaggio è WM_CLOSE (tasto X)
    je .exit

    push msg
    call _DispatchMessageA@4
    jmp .r_loop                 ; Svuota tutta la coda prima di disegnare

.draw:
    push dword [prog]
    call [f_glUP]

    push 122 ; VK_F11
    call _GetAsyncKeyState@4
    test ah, 0x80
    jz .no_f11

    ; Logica di Toggle
    xor dword [is_windowed], 1
    cmp dword [is_windowed], 1
    je .set_windowed

.set_fullscreen:
    push 0x90000000 ; WS_VISIBLE | WS_POPUP
    push -16 ; GWL_STYLE
    push dword [hWnd]
    call _SetWindowLongA@12
    push 3 ; SW_MAXIMIZE
    push dword [hWnd]
    call _ShowWindow@8
    jmp .toggle_done

.set_windowed:
    push 0x10CF0000 ; WS_VISIBLE | WS_OVERLAPPEDWINDOW
    push -16 ; GWL_STYLE
    push dword [hWnd]
    call _SetWindowLongA@12
    push 0x60 ; SWP_FRAMECHANGED | SWP_SHOWWINDOW
    push 480
    push 640
    push 100
    push 100
    push 0
    push dword [hWnd]
    call _SetWindowPos@28

.toggle_done:
    push 300 ; Pausa di 300ms per evitare toggle a raffica
    call _Sleep@4
.no_f11:

    push rect
    push dword [hWnd]
    call _GetClientRect@8
    test eax, eax               ; Se la finestra è stata chiusa o l'handle è invalido, restituisce 0
    jz .exit                    ; Esce dal programma e termina istantaneamente la musica

    ; Prevenzione Viewport 0x0 (Evita schermate bianche se la finestra non è ancora pronta)
    mov eax, [rect+8]
    test eax, eax
    jz .wait_60fps

    push dword [rect+12] ; height
    push dword [rect+8]  ; width
    push 0
    push 0
    call _glViewport@16

    call _timeGetTime@0
    sub eax, [start_time]
    cmp eax, 402000             ; 134s * 3 = 402000ms
    ja .exit                    ; Esci automaticamente dopo 3 loop
        push eax ; Salva il tempo trascorso in ms
    cvtsi2ss xmm0, eax
    mulss xmm0, [f1000]
    movss xmm1, xmm0

    sub esp, 4
    movss [esp], xmm1
    push dword [loc_t]
    call [f_glU1F]

    ; Recupera loc_r salvato in precedenza
    mov edi, [loc_r]

    cvtsi2ss xmm0, [rect+12] ; height
    sub esp, 4
    movss [esp], xmm0
    cvtsi2ss xmm0, [rect+8]  ; width
    sub esp, 4
    movss [esp], xmm0
    push edi
    call [f_glU2F]

    push 1
    push 1
    push -1
    push -1
    call _glRecti@16

    pop eax ; Pulisce lo stack dal tempo
    push dword [hDC_gl]
    call _SwapBuffers@4

    ; --- OTTIMIZZAZIONE FRAME LOOP ---
    ; Rimosso il loop di Sleep(1) aggressivo che causava stuttering su monitor High-Refresh (120Hz)
    ; Usiamo un solo Sleep(1) per non saturare la CPU (4%) e lasciamo che SwapBuffers gestisca il VSync
.wait_60fps:
    push 1
    call _Sleep@4
    jmp .r_loop

.exit:
    push 0
    call _ExitProcess@4