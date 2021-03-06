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

struct TrailParams
{
    vec4 Params;
};

uniform vec4 CB0[47];
uniform vec4 CB1[1];
attribute vec4 POSITION;
attribute vec3 TEXCOORD0;
attribute vec4 TEXCOORD1;
varying vec3 VARYING0;
varying vec4 VARYING1;
varying vec3 VARYING2;

void main()
{
    vec3 v0 = vec3(0.0);
    v0.x = TEXCOORD0.x;
    vec3 v1 = v0;
    v1.y = TEXCOORD0.y;
    vec2 v2 = v1.xy * TEXCOORD0.z;
    vec3 v3 = vec3(v2.x, v2.y, v1.z);
    v3.z = TEXCOORD0.z;
    gl_Position = (POSITION + (CB0[6] * CB1[0].x)) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    VARYING0 = v3;
    VARYING1 = TEXCOORD1 * 0.0039215688593685626983642578125;
    VARYING2 = CB0[7].xyz - POSITION.xyz;
}

