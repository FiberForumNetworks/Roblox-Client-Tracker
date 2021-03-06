#version 150

struct EmitterParams
{
    vec4 ModulateColor;
    vec4 Params;
    vec4 AtlasParams;
};

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec3 Exposure;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 SkyGradientTop_EnvDiffuse;
    vec4 SkyGradientBottom_EnvSpec;
    vec3 AmbientColorNoIBL;
    vec3 SkyAmbientNoIBL;
    vec4 AmbientCube[12];
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlags;
};

uniform vec4 CB1[3];
uniform vec4 CB0[47];
in vec4 POSITION;
in vec4 TEXCOORD0;
in vec2 TEXCOORD1;
in vec4 TEXCOORD2;
in vec2 TEXCOORD3;
out vec3 VARYING0;
out vec4 VARYING1;
out vec2 VARYING2;
out vec4 VARYING3;

void main()
{
    vec2 v0 = (TEXCOORD1 * 2.0) - vec2(1.0);
    vec4 v1 = TEXCOORD0 * vec4(0.00390625, 0.00390625, 0.00019175345369148999452590942382813, 3.0518509447574615478515625e-05);
    vec2 v2 = v1.xy + vec2(127.0);
    float v3 = v1.z;
    float v4 = cos(v3);
    float v5 = sin(v3);
    float v6 = v2.x;
    vec4 v7 = vec4(0.0);
    v7.x = v4 * v6;
    vec4 v8 = v7;
    v8.y = (-v5) * v6;
    float v9 = v2.y;
    vec4 v10 = v8;
    v10.z = v5 * v9;
    vec4 v11 = v10;
    v11.w = v4 * v9;
    vec4 v12 = (POSITION + (CB0[4] * dot(v0, v11.xy))) + (CB0[5] * dot(v0, v11.zw));
    mat4 v13 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v14 = v12 * v13;
    vec3 v15 = vec3(TEXCOORD1.x, TEXCOORD1.y, vec3(0.0).z);
    v15.y = 1.0 - TEXCOORD1.y;
    float v16 = v14.w;
    vec3 v17 = v15;
    v17.z = (CB0[13].z - v16) * CB0[13].w;
    vec4 v18 = (v12 + (CB0[6] * CB1[1].x)) * v13;
    vec4 v19 = v14;
    v19.z = (v18.z * v16) / v18.w;
    vec2 v20 = (vec2(0.5) * (v19.xy / vec2(v16)).xy) + vec2(0.5);
    vec3 v21 = vec3(v20.x, v20.y, vec3(0.0).z);
    v21.z = min(v16 - CB1[1].x, 495.0);
    vec4 v22 = vec4(v21.x, v21.y, v21.z, vec4(0.0).w);
    v22.w = 1.0 / v6;
    vec2 v23 = (TEXCOORD3 + ((TEXCOORD1 * (CB1[2].z - 1.0)) + vec2(0.5))) * CB1[2].xy;
    vec2 v24 = v23;
    v24.y = 1.0 - v23.y;
    gl_Position = v19;
    VARYING0 = v17;
    VARYING1 = TEXCOORD2 * 0.0039215688593685626983642578125;
    VARYING2 = v24;
    VARYING3 = v22;
}

