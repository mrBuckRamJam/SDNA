# SDNA

```text
    ____  ___    __  ___      __  ___    __  ___
   / __ \/   |  /  |/  /     / / /   |  /  |/  /
  / /_/ / /| | / /|_/ / __  / / / /| | / /|_/ / 
 / _, _/ ___ |/ /  / / / /_/ / / ___ |/ /  / /  
/_/ |_/_/  |_/_/  /_/  \____/_/_/  |_/_/  /_/   
                                                
```
for ROMA.EXE - 4K INTRO: SDNA - an hypnotic organic cell journey .
Coded by: Mr.Buck Ram Jam - 09/05/2026 - 12:55.
Toolkits: NASM + CRINKLER + 4kLANG.

SCENER DNA - 4k Intro (limited to 4096 bytes) in x86 Assembly for Windows - Technical Details:

- Engine: Pixel Shader (GLSL) featuring Raymarching with Signed Distance Fields (SDF) for organic geometries, integrated into a custom Assembly mini-framework;
- Visual Effects: Soft Shadows, Ambient Occlusion, and SSS (Subsurface Scattering) to provide cells with a translucent, fleshy appearance, deterministic pseudo-random hashing to deform cell wall geometries and create surface micro-details, volumetric fog for spatial depth and suspended particles (e.g., dust or globules).

1. Architecture and Compression (The "Container"):
-x86 Assembly (NASM): 32-bit assembly language source code;
- Crinkler: used to link objects and compress the entire program into a tiny executable (under 4096 bytes).

2. Graphics: 

- Raymarching Engine (The Shader): the core logic resides in the GLSL Pixel Shader stored in the .data section;
- Raymarching Technique: unlike traditional triangle-based graphics, we cast rays from the camera and, for every pixel, the shader calculates the distance between the ray and the nearest object;
- SDF (Signed Distance Fields): Objects are mathematical equations rather than 3D models:

	- Tunnel: Created by subtracting a deformed cylinder from a solid space;
	- DNA: Built using SDFs of cylinders and capsules rotating around an axis;
	- Organic Heart: Achieved by blending multiple spheres and ellipsoids using the smin function;
	- Organic Fusing (smin): The "Smooth Minimum" function allows objects to "merge" like mercury or flesh, creating a biological look;
	- Noise/Hash Deformation: The h(vec3 p) function acts as a textureless procedural hash. It is used to randomly displace particles and ripple the tunnel walls, avoiding mathematical perfection.

3. Lighting and Post-Processing:Advanced techniques implemented to simulate microscopic depth:

- Ambient Occlusion (AO): calculated via the ao function to simulate how light struggles to reach tight corners, creating dark shadows in the folds of the tunnel and the heart;
- Subsurface Scattering (SSS): simulated by calculating ray distance inside objects (ss). This creates the "translucent flesh" effect where light appears to penetrate the surface;
- Fresnel Reflections: using the fr variable to brighten object edges at grazing angles, simulating the sheen of mucus or biological fluids;
- Volumetric Fog: uses ray distance (tr) to mix the final color with a background color, adding depth to the tunnel.

4. Audio via Procedural Synthesis:

- 4klang: Integration of the renowned software synthesizer for 4k demos;
- Offline Rendering: to save CPU cycles, the program calls _4klang_render at startup. This generates the entire audio track into a memory buffer (sound_buffer);
- WinMM API: uses waveOutOpen, waveOutPrepareHeader, and waveOutWrite to stream the audio buffer directly to the sound card—the most lightweight method for audio handling on Windows.

5. Logic and Synchronization:

- System Timer: Uses _timeGetTime@0 to retrieve elapsed time, passed to the shader as the t uniform;
- Scripting (Timeline): Within the shader, we use mt = mod(t, 134.) and smoothstep to trigger different phases:
	- sk: transition from the narrow tunnel to the opening;
	- rev: phase for text overlays;
	- fin: demo outro;
- 60 FPS Lock: in the main loop (.wait_60fps), current time is compared to the previous frame, utilizing **V-Sync (wglSwapIntervalEXT)** to synchronize rendering with the monitor's refresh rate; this prevents the demo from running too quickly on modern systems;
- Toggle Fullscreen (F11): Uses _SetWindowLongA to create a borderless popup window and _SetWindowPos for resizing.

Summary: we utilized Assembly for the structure, 4klang for generative music, OpenGL for the graphics pipeline, and a mathematical Pixel Shader to generate an entire 3D world without a single polygon or external texture. 
Everything is "packed" by Crinkler to stay strictly within the 4K category limits.





