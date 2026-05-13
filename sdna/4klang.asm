; *****************************************************************
; * 4klang engine + "Slow & Heavy" Track Data                     *
; *****************************************************************

%include "4klang.inc"

global _4klang_render@4

; Macro mancanti per la struttura della traccia
%macro GO4K_BEGIN_INST 0
%endmacro
%macro GO4K_END_INST 0
%endmacro

%define SAW     TRISAW
%define C_2     36
%define C_3     48
%define G_1     31
%define G_2     43
%define C_1     24
%define E_2     40
%define F_2     41
%define A_2     45
%define A_4     69
%define E_3     52
%define MAX_CHANNELS 8
%define MAX_TICKS_LOOP 512 ; 32 pattern * 16 note
%define F_PITCH_FAC 0.0000185 ; Costante per conversione frequenza

section .data

align 4
go4k_inst_spec:
    ; STRUMENTO 1: THE VEIN
    GO4K_BEGIN_INST 
        db GO4K_VCO_ID, SINE, 0, 64, 0, 64, 128
        db GO4K_VCO_ID, SAW, 0, 64, 1, 64, 128
        db GO4K_FOP_ID, FOP_ADD
        db GO4K_VCF_ID, LOWPASS, 20, 30
        db GO4K_ENV_ID, 120, 0, 128, 120, 128
        db GO4K_DLL_ID, 1, 64, 100, 0, 40, 1, 1
        db GO4K_PAN_ID, 64
        db GO4K_OUT_ID, 128, 0
    GO4K_END_INST 

    ; STRUMENTO 2: SUB PRESSURE
    GO4K_BEGIN_INST 
        db GO4K_VCO_ID, SINE, -12, 64, 0, 64, 128
        db GO4K_VCF_ID, LOWPASS, 15, 0
        db GO4K_ENV_ID, 127, 0, 128, 127, 128
        db GO4K_PAN_ID, 64
        db GO4K_OUT_ID, 128, 0
    GO4K_END_INST 

    ; STRUMENTO 3: THE HEART
    GO4K_BEGIN_INST 
        db GO4K_VCO_ID, SINE, -24, 64, 0, 64, 128
        db GO4K_VCO_ID, TRISAW, -24, 64, 0, 64, 128
        db GO4K_FOP_ID, FOP_ADD
        db GO4K_FST_ID, 60, FST_SET | 0 ; Pitch kick
        db GO4K_DST_ID, 95, 0, 0
        db GO4K_VCF_ID, LOWPASS, 30, 80
        db GO4K_ENV_ID, 0, 80, 0, 60, 128
        db GO4K_PAN_ID, 64
        db GO4K_OUT_ID, 128, 0
    GO4K_END_INST 
go4k_inst_spec_end:

align 4
go4k_note_list:
    ; Canale 1
    %rep 32
        db C_2, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD
    %endrep
    ; Canale 2
    %rep 32
        db C_3, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD
    %endrep
    ; Canale 3
    %rep 3 ; Silenzio iniziale (~6s)
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    %rep 14 ; Ridotto per il loop a 32
        db C_2, 0, 0, C_2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; Doppio
        db C_2, 0, 0, C_2, 0, 0, C_2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; Triplo
    %endrep
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; Filler
    ; Canale 4: Kick Drum (Entra insieme al cuore)
    %rep 3
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    %rep 29
        db C_2, 0, 0, 0, C_2, 0, 0, 0, C_2, 0, 0, 0, C_2, 0, 0, 0
    %endrep
    ; Canale 5: Melodia Sincopata (Entra a 20s = 10 pattern)
    %rep 10
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    %rep 5 ; Loop "Corno da Guerra" (5 cicli * 4 pattern = 20 pattern)
        db C_1, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD ; Booooong (2s)
        db HLD, HLD, HLD, HLD, HLD, HLD, HLD, HLD, 0, 0, 0, 0, 0, 0, 0, 0                 ; Coda + Inizio Stop (1s+1s)
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0                                 ; Stop (2s)
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0                                 ; Stop (2s)
    %endrep
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; Filler
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ; Canale 6: Melodia Principale (Entra prima a 20s = 10 pattern)
    %rep 10
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    %rep 22 ; Note costanti (senza note_boost statico)
        db A_2, HLD, HLD, HLD, G_2, HLD, HLD, HLD, F_2, HLD, HLD, HLD, E_2, HLD, HLD, HLD
    %endrep
    ; Canale 7: The Bark (abbaio veloce)
    %rep 16 ; 16 cicli di [Pattern note + Pattern silenzio] = 32 pattern
        db A_4, HLD, A_4, HLD, 0, 0, A_4, HLD, A_4, HLD, 0, 0, 0, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    ; Canale 8: The Wah-Wah Guitar (Inizia molto prima, a ~33s)
    %rep 8
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
    %rep 12 ; 12 cicli di [Burst + Pausa] = 24 pattern. Totale 32.
        db E_3, 0, 0, 0, E_3, 0, 0, 0, E_3, 0, E_3, 0, E_3, 0, 0, 0
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    %endrep
go4k_note_list_end:

align 4
go4k_parameter_list:
    db 0, 0, 128, 64, 0, 0, 64, 1, 0, 128, 64, 0, 0, 64, 20, 30, 120, 0, 128, 120, 1, 64, 100, 0, 40, 64
    db -12, 0, 128, 64, 0, 0, 64, 15, 0, 127, 0, 128, 127, 64
    db -24, 0, 128, 64, 0, 0, 64, -24, 0, 128, 64, 0, 0, 64, 60, 0, 0, 40, 95, 30, 80, 0, 80, 0, 60, 64

align 4
go4k_delay_times:
    dw 1111, 2222, 3333, 4444

section .bss
    alignb 4
    go4k_synth_buffer resb go4k_synth.size
    ; Variabili di lavoro per il pre-rendering
    channel_note    resd MAX_CHANNELS
    channel_phase   resd MAX_CHANNELS
    channel_env     resd MAX_CHANNELS
    channel_freq    resd MAX_CHANNELS
    channel_attack  resd MAX_CHANNELS
    channel_gain    resd MAX_CHANNELS
    channel_pitch_add resd MAX_CHANNELS
    channel_filter_state resd MAX_CHANNELS
    ; Buffer per il delay del lead (65536 campioni)
    lead_delay_buffer  resd 65536
    lead_delay_idx     resd 1
    ; Buffer per il delay della melodia (65536 campioni = ~1.5 secondi)
    pluck_delay_buffer resd 65536
    pluck_delay_idx    resd 1

section .text

; --- FUNZIONE DI RENDERING CORE ---
_4klang_render@4:
    pushad
    mov edi, [esp+36]       ; EDI = sound_buffer (destinazione)
    
    xor ecx, ecx
.sample_loop:
    ; Ogni volta che ecx è multiplo di SAMPLES_PER_TICK, carichiamo nuove note
    push ecx
    mov eax, ecx
    xor edx, edx
    mov ebx, SAMPLES_PER_TICK
    div ebx
    test edx, edx
    jnz .process_samples

    ; --- TICK UPDATE (Cambio nota) ---
    ; eax contiene l'indice del tick attuale
    mov ebx, eax            ; ebx = tick assoluto
    and ebx, MAX_TICKS_LOOP - 1 ; LOOP LOGIC: Forza il ritorno all'inizio ogni 32 pattern
    
    ; Reset parametri evolutivi all'inizio di ogni loop per "ripartire da zero"
    test ebx, ebx
    jnz .no_param_reset
    xor edx, edx
.reset_param_loop:
    mov dword [channel_gain + edx*4], 0
    mov dword [channel_pitch_add + edx*4], 0
    mov dword [channel_filter_state + edx*4], 0
    mov dword [channel_freq + edx*4], 0       ; Reset frequenze residue
    mov dword [channel_env + edx*4], 0        ; Reset inviluppi per evitare code nel loop
    inc edx
    cmp edx, MAX_CHANNELS
    jl .reset_param_loop
.no_param_reset:

    xor esi, esi
.tick_ch_loop:
    ; Calcolo indice nella note_list: (canale * MAX_TICKS) + tick
    imul edx, esi, MAX_TICKS_LOOP
    add edx, ebx
    mov al, [go4k_note_list + edx]
    test al, al
    jz .no_new_note
    cmp al, HLD
    je .no_new_note
    
    ; Nuova nota: reset inviluppo
    mov [channel_note + esi*4], al
    movzx eax, al           ; Carica il valore della nota (0-127) in eax
    mov dword [channel_env + esi*4], 0x3F800000 ; Env = 1.0
    mov dword [channel_attack + esi*4], 0        ; Reset attack per il lead

    ; Logica Evolutiva Dinamica (Canale 5)
    cmp esi, 5
    jne .skip_gain_inc
    ; Incremento Pitch (Grido)
    movss xmm1, [channel_pitch_add + esi*4]
    addss xmm1, [f_pitch_inc]
    movss [channel_pitch_add + esi*4], xmm1
    ; Incremento volume
    movss xmm1, [channel_gain + esi*4]
    addss xmm1, [f_gain_inc]
    movss [channel_gain + esi*4], xmm1
.skip_gain_inc:

    ; Se è il canale del Kick (3), usa una frequenza di partenza più alta per lo slide
    cmp esi, 3
    jne .not_kick_trigger
    movss xmm0, [f_kick_start]
    movss [channel_freq + esi*4], xmm0
    jmp .no_new_note

.not_kick_trigger:
    ; Freq approx: (nota + boost) * costante
    cvtsi2ss xmm0, eax
    addss xmm0, [channel_pitch_add + esi*4] ; Applica il boost dinamico al pitch
    mulss xmm0, [f_pitch_const]
    movss [channel_freq + esi*4], xmm0

.no_new_note:
    inc esi
    cmp esi, MAX_CHANNELS
    jl .tick_ch_loop

.process_samples:
    ; --- SAMPLE GENERATION ---
    fldz                    ; Accumulatore Left
    xor esi, esi
.ch_sample_loop:
    movss xmm0, [channel_phase + esi*4]
    addss xmm0, [channel_freq + esi*4]
    ; Clamp fase a 1.0
    movss xmm1, [f_1]
    comiss xmm0, xmm1
    jb .no_phase_wrap
    subss xmm0, xmm1
.no_phase_wrap:
    movss [channel_phase + esi*4], xmm0
    
    ; Generazione onda base
    cmp esi, 7
    je .wah_processing       ; Chitarra elettrica

    subss xmm0, [f_05]       ; SINE approx per altri strumenti

    cmp esi, 6
    je .bark_processing
    cmp esi, 5
    je .lead_processing
    cmp esi, 4
    je .pluck_processing
    cmp esi, 3
    jne .melodic_processing

    ; --- LOGICA KICK (Canale 3) ---
    movss xmm1, [channel_freq + esi*4]
    mulss xmm1, [f_kick_slide]
    movss [channel_freq + esi*4], xmm1
    
    movss xmm1, [channel_env + esi*4]
    mulss xmm1, [f_kick_decay]
    movss [channel_env + esi*4], xmm1
    
    mulss xmm0, xmm1         ; Applica inviluppo kick
    mulss xmm0, [f_kick_gain] ; BOOST KICK
    jmp .accumulate

.wah_processing:
    addss xmm0, xmm0         ; Saw wave base (-1.0 a 1.0)
    
    ; --- BENDING UMANO PROTETTO ---
    ; Applica il bending solo se la nota è attiva (env > 0.001)
    movss xmm1, [channel_env + esi*4]
    comiss xmm1, [f_001]
    jbe .no_bend_active
    movss xmm1, [channel_freq + esi*4]
    mulss xmm1, [f_wah_bend] ; Alza il pitch impercettibilmente ogni campione
    movss [channel_freq + esi*4], xmm1
.no_bend_active:

    ; --- DISTORSIONE CHITARRA (Soft Clipping) ---
    mulss xmm0, [f_wah_drive]
    movss xmm1, [f_1]
    comiss xmm0, xmm1
    jbe .no_pos_clip
    movss xmm0, xmm1
.no_pos_clip:
    xorps xmm2, xmm2
    subss xmm2, xmm1         ; xmm2 = -1.0
    comiss xmm0, xmm2
    jae .no_neg_clip
    movss xmm0, xmm2
.no_neg_clip:

    ; --- WAH DINAMICO E ACCELERATO ---
    movss xmm2, [f_wah_lfo_speed]
    ; Accelerazione globale: dal Pattern 20 in poi (tick 320) raddoppia velocità base
    cmp ebx, 320 
    jl .burst_1
    addss xmm2, xmm2 
.burst_1:
    ; Accelerazione interna alla nota: usa l'inviluppo (1.0 -> 0.0) 
    ; lfo_speed *= (1.5 - env). Più la nota muore, più il wah mastica veloce.
    movss xmm3, [f_1_5]
    subss xmm3, [channel_env + esi*4]
    mulss xmm2, xmm3

    cvtsi2ss xmm1, [esp]     ; ecx (tempo assoluto)
    mulss xmm1, xmm2
    sub esp, 4
    movss [esp], xmm1
    fld dword [esp]
    fsin
    fstp dword [esp]
    movss xmm1, [esp]        ; xmm1 = -1 a 1
    add esp, 4
    addss xmm1, [f_1]        ; 0 a 2
    mulss xmm1, [f_05]       ; 0 a 1 (LFO modulante)
    
    mulss xmm1, [f_wah_cutoff_range]
    addss xmm1, [f_wah_cutoff_min]   ; xmm1 = Alpha del filtro
    
    ; Filtro LPF 1-pole: y = y + alpha * (x - y)
    movss xmm2, [channel_filter_state + esi*4]
    movss xmm3, xmm0
    subss xmm3, xmm2
    mulss xmm3, xmm1
    addss xmm2, xmm3
    movss [channel_filter_state + esi*4], xmm2
    
    ; Applica Inviluppo per evitare click
    mulss xmm2, [channel_env + esi*4]
    ; Decadimento specifico per chitarra
    movss xmm3, [channel_env + esi*4]
    mulss xmm3, [f_lead_decay] ; Usa il decay lungo del lead
    movss [channel_env + esi*4], xmm3

    movss xmm0, xmm2
    mulss xmm0, [f_wah_gain]
    jmp .accumulate

.bark_processing:
    ; Onda Saw: (fase-0.5)*2 per un suono più ruvido
    addss xmm0, xmm0         ; xmm0 = -1.0 a 1.0
    
    ; Inviluppo percussivo veloce
    movss xmm1, [channel_env + esi*4]
    mulss xmm1, [f_bark_decay]
    movss [channel_env + esi*4], xmm1

    ; Effetto "WaaWaa" (modulazione ciclica veloce)
    cvtsi2ss xmm2, [esp]     ; tempo basato sui campioni
    mulss xmm2, [f_bark_wobble_speed]
    sub esp, 4
    movss [esp], xmm2
    fld dword [esp]
    fmul dword [f_2pi]
    fsin                     ; LFO
    fstp dword [esp]
    movss xmm2, [esp]
    add esp, 4
    addss xmm2, [f_1]        ; sposta a 0.0 - 2.0
    mulss xmm2, [f_05]       ; scala a 0.0 - 1.0 (wobble)

    mulss xmm0, xmm1         ; applica env
    mulss xmm0, xmm2         ; applica waawaa
    mulss xmm0, [f_bark_gain]
    jmp .accumulate

.pluck_processing:
    ; --- LOGICA PLUCK (Canale 4) CON DELAY (SPAZIALITÀ) ---
    movss xmm1, [channel_env + esi*4]
    mulss xmm1, [f_pluck_decay]
    movss [channel_env + esi*4], xmm1
    
    mulss xmm0, xmm1
    mulss xmm0, [f_pluck_gain]

    ; Recupera il campione ritardato dal buffer
    mov ebx, [pluck_delay_idx]
    movss xmm1, [pluck_delay_buffer + ebx*4]
    
    ; Mix: Segnale = Attuale + (Ritardato * Feedback)
    movss xmm2, xmm1
    mulss xmm2, [f_delay_fb]
    addss xmm0, xmm2
    
    ; Salva il risultato nel buffer per il prossimo ciclo di feedback
    movss [pluck_delay_buffer + ebx*4], xmm0
    
    ; Incrementa l'indice del buffer (modulo 65536)
    inc ebx
    and ebx, 0xFFFF 
    mov [pluck_delay_idx], ebx
    jmp .accumulate

.lead_processing:
    ; --- LOGICA LEAD (Canale 5) - Sine, Vibrato, Attack, Delay ---
    ; Vibrato: modula la fase con un LFO lento (usa ecx salvato nello stack)
    cvtsi2ss xmm1, [esp]    
    mulss xmm1, [f_vibrato_speed]
    sub esp, 4
    movss [esp], xmm1
    fld dword [esp]
    fsin

    ; --- EFFETTO WAAAAWAAAA (Solo ultimi 20 secondi del loop) ---
    ; ebx contiene il tick attuale (0-511). 352 è l'inizio degli ultimi 20s.
    cmp ebx, 352
    jl .skip_wobble
    
    ; Calcola LFO per il wobble usando ecx (indice campione)
    cvtsi2ss xmm2, [esp+4]   ; Recupera ecx salvato
    mulss xmm2, [f_wobble_speed]
    sub esp, 4
    movss [esp], xmm2
    fld dword [esp]
    fsin                    ; st0 = sin(wobble)
    fstp dword [esp]
    movss xmm2, [esp]       ; xmm2 = wobble (-1.0 a 1.0)
    addss xmm2, [f_1]       ; sposta a 0.0 - 2.0
    mulss xmm2, [f_05]      ; scala a 0.0 - 1.0
    mulss xmm0, xmm2        ; Modula l'ampiezza (il "waaaa")
    add esp, 4
.skip_wobble:

    ; Effetto Grido: aumenta il vibrato con l'altezza della nota
    movzx eax, byte [channel_note + esi*4]
    cvtsi2ss xmm1, eax
    mulss xmm1, [f_vibrato_depth]
    mulss xmm1, [f_001]     ; Riscala il valore per un'escursione udibile ma non folle
    movss [esp], xmm1
    fmul dword [esp]        ; st0 = sin(LFO) * depth_proporzionale_alla_nota
    
    fstp dword [esp]
    addss xmm0, [esp]       ; Applica vibrato alla fase
    
    ; Generazione SINE reale tramite FPU
    movss [esp], xmm0
    fld dword [esp]
    fmul dword [f_2pi]
    fsin
    fstp dword [esp]
    movss xmm0, [esp]
    add esp, 4

    ; Gestione Inviluppo: Attack graduale + Decay
    movss xmm1, [channel_attack + esi*4]
    movss xmm2, [f_1]
    subss xmm2, xmm1
    mulss xmm2, [f_lead_attack_speed]
    addss xmm1, xmm2
    movss [channel_attack + esi*4], xmm1
    
    mulss xmm0, xmm1         ; Applica l'attacco (fade-in)
    mulss xmm0, [channel_env + esi*4] ; Applica il decadimento
    mulss xmm0, [channel_gain + esi*4] ; Volume dinamico

    ; Delay specifico per il Lead per massima spazialità
    mov ebx, [lead_delay_idx]
    movss xmm1, [lead_delay_buffer + ebx*4]
    movss xmm2, xmm1
    mulss xmm2, [f_delay_fb_lead]
    addss xmm0, xmm2
    movss [lead_delay_buffer + ebx*4], xmm0
    inc ebx
    and ebx, 0xFFFF
    mov [lead_delay_idx], ebx
    jmp .accumulate

.melodic_processing:
    mulss xmm0, [channel_env + esi*4] ; Applica inviluppo melodico
    ; Decadimento inviluppo melodico
    movss xmm1, [channel_env + esi*4]
    mulss xmm1, [f_env_decay]
    movss [channel_env + esi*4], xmm1

.accumulate:
    mulss xmm0, [f_vol_master]
    
    sub esp, 4              ; Spazio temporaneo sullo stack
    movss [esp], xmm0       ; Sposta il campione calcolato in SSE nello stack
    fadd dword [esp]        ; Somma il valore al registro st0 della FPU
    add esp, 4              ; Ripristina lo stack

    inc esi
    cmp esi, MAX_CHANNELS
    jl .ch_sample_loop

    ; Scrittura buffer Stereo Float
    fst dword [edi]         ; Left
    fstp dword [edi+4]      ; Right
    add edi, 8

    pop ecx
    inc ecx
    cmp ecx, MAX_SAMPLES
    jl .sample_loop
    popad
    ret 4

;section .data
;    f_pitch_const dd 0.0001
;    f_1           dd 1.0
;    f_05          dd 0.5
;    f_vol_master  dd 0.05    ; Volume generale basso per far risaltare il kick
;    f_env_decay   dd 0.99995 ; Decadimento molto lento per il drone
;    f_kick_start  dd 0.002   ; Frequenza iniziale del kick ridotta per evitare fruscii
;    f_kick_slide  dd 0.9992  ; Velocità del pitch drop
;    f_kick_decay  dd 0.999   ; Decadimento volume del kick
;    f_kick_gain   dd 6.68    ; 7.68 Guadagno per il kick (ridotto di un ulteriore 20%)

    section .data
    f_pitch_const dd 0.0001
    f_1           dd 1.0
    f_05          dd 0.5
    f_vol_master  dd 0.6     ; Master volume al 60%
    f_env_decay   dd 0.9995  ; Drone più corto: un drone infinito satura il buffer
    f_kick_start  dd 0.04    ; Frequenza iniziale MOLTO più alta per il "click" del martello
    f_kick_slide  dd 0.992   ; Slide più veloce (0.992 invece di 0.9992) per un colpo secco
    f_kick_decay  dd 0.998   ; Decadimento volume più rapido per evitare code fangose
    f_kick_gain   dd 3.5     ; Ridotto drasticamente (da 6.68 a 3.5). Il kick distorceva per clipping.
    f_pluck_decay dd 0.9999  ; Decadimento ripristinato a un valore più lungo
    f_pluck_gain  dd 1.2     ; Volume ridotto per un inserimento più morbido nel mix
    f_delay_fb    dd 0.55    ; Eco ridotto (più basso) come richiesto
    f_lead_decay  dd 0.99992 ; Note molto più lunghe
    f_gain_inc    dd 0.0017  ; Incremento per arrivare a ~0.35 dopo 200 note
    f_lead_attack_speed dd 0.0005 ; Attacco più rapido per adattarsi alle note brevi
    f_vibrato_speed dd 0.0007
    f_vibrato_depth dd 0.012   ; Aumentato per rendere il grido finale più drammatico
    f_2pi           dd 6.283185
    f_delay_fb_lead dd 0.82    ; Molto più eco per il lead
    f_001           dd 0.01
    f_pitch_inc     dd 0.1     ; Incremento di ~1/10 di semitono per ogni nuova nota
    f_wobble_speed  dd 0.0009  ; Velocità del waaaawaaaa
    f_wobble_depth  dd 0.5
    f_bark_decay    dd 0.9994  ; Decadimento rapido
    f_bark_gain     dd 0.45    ; Volume dello strumento
    f_bark_wobble_speed dd 0.007 ; Velocità dell'effetto waawaa
    f_wah_lfo_speed  dd 0.0004 ; Wah base più lento
    f_wah_cutoff_min dd 0.02   ; Taglio base
    f_wah_cutoff_range dd 0.45 ; Apertura ancora più estrema
    f_wah_gain       dd 0.9    ; Volume molto più alto
    f_wah_drive      dd 4.0    ; Più distorsione
    f_wah_bend       dd 1.00002 ; Slide del pitch verso l'alto (Bending)
    f_1_5            dd 1.5
