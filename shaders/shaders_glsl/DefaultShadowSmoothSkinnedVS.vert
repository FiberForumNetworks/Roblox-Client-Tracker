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
uniform vec4 CB1[216];
attribute vec4 POSITION;
attribute vec4 TEXCOORD1;
attribute vec4 TEXCOORD2;
varying vec3 VARYING0;

void main()
{
    vec4 v0 = TEXCOORD2 * vec4(0.0039215688593685626983642578125);
    int v1 = int(TEXCOORD1.x) * 3;
    float v2 = v0.x;
    int v3 = int(TEXCOORD1.y) * 3;
    float v4 = v0.y;
    int v5 = int(TEXCOORD1.z) * 3;
    float v6 = v0.z;
    int v7 = int(TEXCOORD1.w) * 3;
    float v8 = v0.w;
    vec4 v9 = vec4(dot((((CB1[v1 * 1 + 0] * v2) + (CB1[v3 * 1 + 0] * v4)) + (CB1[v5 * 1 + 0] * v6)) + (CB1[v7 * 1 + 0] * v8), POSITION), dot((((CB1[(v1 + 1) * 1 + 0] * v2) + (CB1[(v3 + 1) * 1 + 0] * v4)) + (CB1[(v5 + 1) * 1 + 0] * v6)) + (CB1[(v7 + 1) * 1 + 0] * v8), POSITION), dot((((CB1[(v1 + 2) * 1 + 0] * v2) + (CB1[(v3 + 2) * 1 + 0] * v4)) + (CB1[(v5 + 2) * 1 + 0] * v6)) + (CB1[(v7 + 2) * 1 + 0] * v8), POSITION), 1.0);
    gl_Position = v9 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    VARYING0 = vec3(dot(CB0[20], v9), dot(CB0[21], v9), dot(CB0[22], v9));
}

