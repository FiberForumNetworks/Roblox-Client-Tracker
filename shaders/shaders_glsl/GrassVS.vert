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

struct GrassParams
{
    vec4 Offset;
    vec4 Dist_HeightFade;
};

struct GrassPerFrameParams
{
    vec4 grassColor0;
    vec4 grassColor1;
    vec4 data;
};

uniform vec4 CB0[47];
uniform vec4 CB1[2];
uniform vec4 CB2[3];
attribute vec4 POSITION;
attribute vec4 NORMAL;
varying vec4 VARYING0;
varying vec3 VARYING1;
varying vec3 VARYING2;
varying vec3 VARYING3;

void main()
{
    bool v0 = NORMAL.w >= 0.5;
    vec4 v1 = POSITION * vec4(0.00390625);
    vec3 v2 = v1.xyz + CB1[0].xyz;
    vec3 v3 = NORMAL.xyz * 2.0;
    float v4 = v2.y - (smoothstep(0.0, 1.0, 1.0 - ((CB1[1].x - length(CB0[7].xyz - v2)) * CB1[1].y)) * v1.w);
    vec3 v5 = v2;
    v5.y = v4;
    vec4 v6 = vec4(v2.x, v4, v2.z, 1.0);
    bvec3 v7 = bvec3(v0);
    gl_Position = v6 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    VARYING0 = vec4(((v5 + vec3(0.0, 6.0, 0.0)).yxz * CB0[16].xyz) + CB0[17].xyz, (CB0[13].x * length(CB0[7].xyz - v5)) + CB0[13].y);
    VARYING1 = vec3(dot(CB0[20], v6), dot(CB0[21], v6), dot(CB0[22], v6));
    VARYING2 = (CB0[10].xyz * clamp((dot((v3 - vec3(1.0)) * sign(dot(CB0[11].xyz, vec3(1.0) - v3)), -CB0[11].xyz) + 0.89999997615814208984375) * 0.52631580829620361328125, 0.0, 1.0)) * exp2((-clamp((v0 ? (NORMAL.w - 0.5) : NORMAL.w) * 2.0, 0.0, 1.0)) * CB2[2].x);
    VARYING3 = vec3(v7.x ? CB2[1].xyz.x : CB2[0].xyz.x, v7.y ? CB2[1].xyz.y : CB2[0].xyz.y, v7.z ? CB2[1].xyz.z : CB2[0].xyz.z);
}

