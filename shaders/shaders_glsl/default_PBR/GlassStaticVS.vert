#version 110

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

uniform vec4 CB0[47];
attribute vec4 POSITION;
attribute vec4 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec2 TEXCOORD1;
attribute vec4 COLOR0;
attribute vec4 COLOR1;
varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec3 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;
varying vec4 VARYING7;
varying float VARYING8;

void main()
{
    vec3 v0 = (NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    vec3 v1 = -CB0[11].xyz;
    float v2 = dot(v0, v1);
    vec3 v3 = CB0[7].xyz - POSITION.xyz;
    vec4 v4 = vec4(POSITION.xyz, 1.0);
    vec4 v5 = v4 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v6 = vec4(v3, v5.w);
    float v7 = COLOR0.w * 2.0;
    float v8 = clamp(v7 - 1.0, 0.0, 1.0);
    float v9 = (clamp(2.0 - (dot(v0, normalize(v6.xyz)) * 3.0), 0.0, 1.0) * 0.300000011920928955078125) * clamp(v7, 0.0, 1.0);
    vec4 v10 = COLOR0;
    v10.w = mix(v8, 1.0, v9);
    vec4 v11 = vec4(dot(CB0[20], v4), dot(CB0[21], v4), dot(CB0[22], v4), 0.0);
    v11.w = mix((COLOR1.w * 0.0039215688593685626983642578125) * v8, 1.0, v9);
    float v12 = COLOR1.y * 0.50359570980072021484375;
    float v13 = clamp(v2, 0.0, 1.0);
    vec3 v14 = (CB0[10].xyz * v13) + (CB0[12].xyz * clamp(-v2, 0.0, 1.0));
    vec4 v15 = vec4(v14.x, v14.y, v14.z, vec4(0.0).w);
    v15.w = (v13 * CB0[23].w) * (COLOR1.y * exp2((v12 * dot(v0, normalize(v1 + normalize(v3)))) - v12));
    gl_Position = v5;
    VARYING0 = TEXCOORD0;
    VARYING1 = TEXCOORD1;
    VARYING2 = v10;
    VARYING3 = ((POSITION.xyz + (v0 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    VARYING4 = v6;
    VARYING5 = vec4(v0, COLOR1.z);
    VARYING6 = v15;
    VARYING7 = v11;
    VARYING8 = NORMAL.w;
}

