#version 150

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

struct LightShadowGPUTransform
{
    mat4 transform;
};

uniform vec4 CB0[47];
uniform vec4 CB8[24];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;

in vec4 VARYING0;
in vec3 VARYING1;
in vec3 VARYING2;
in vec4 VARYING3;
in vec3 VARYING4;
out vec4 _entryPointOutput;

void main()
{
    float f0 = clamp(dot(step(CB0[19].xyz, abs(VARYING0.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f1 = VARYING0.yzx - (VARYING0.yzx * f0);
    vec4 f2 = vec4(clamp(f0, 0.0, 1.0));
    vec4 f3 = mix(texture(LightMapTexture, f1), vec4(0.0), f2);
    vec4 f4 = mix(texture(LightGridSkylightTexture, f1), vec4(1.0), f2);
    float f5 = f4.y;
    vec3 f6 = VARYING1 - CB0[41].xyz;
    vec3 f7 = VARYING1 - CB0[42].xyz;
    vec3 f8 = VARYING1 - CB0[43].xyz;
    vec4 f9 = vec4(VARYING1, 1.0) * mat4(CB8[((dot(f6, f6) < CB0[41].w) ? 0 : ((dot(f7, f7) < CB0[42].w) ? 1 : ((dot(f8, f8) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f6, f6) < CB0[41].w) ? 0 : ((dot(f7, f7) < CB0[42].w) ? 1 : ((dot(f8, f8) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f6, f6) < CB0[41].w) ? 0 : ((dot(f7, f7) < CB0[42].w) ? 1 : ((dot(f8, f8) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f6, f6) < CB0[41].w) ? 0 : ((dot(f7, f7) < CB0[42].w) ? 1 : ((dot(f8, f8) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f10 = textureLod(ShadowAtlasTexture, f9.xy, 0.0);
    vec2 f11 = vec2(0.0);
    f11.x = CB0[45].z;
    vec2 f12 = f11;
    f12.y = CB0[45].w;
    float f13 = (2.0 * f9.z) - 1.0;
    float f14 = exp(CB0[45].z * f13);
    float f15 = -exp((-CB0[45].w) * f13);
    vec2 f16 = (f12 * CB0[46].y) * vec2(f14, f15);
    vec2 f17 = f16 * f16;
    float f18 = f10.x;
    float f19 = max(f10.y - (f18 * f18), f17.x);
    float f20 = f14 - f18;
    float f21 = f10.z;
    float f22 = max(f10.w - (f21 * f21), f17.y);
    float f23 = f15 - f21;
    float f24 = mix(f5, mix(min((f14 <= f18) ? 1.0 : clamp(((f19 / (f19 + (f20 * f20))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f15 <= f21) ? 1.0 : clamp(((f22 / (f22 + (f23 * f23))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f5, clamp((length(VARYING1 - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x);
    _entryPointOutput = vec4(mix(CB0[14].xyz, sqrt(clamp((((min((f3.xyz * (f3.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f4.x)), vec3(CB0[16].w)) + (VARYING2 * f24)) * VARYING4) + ((((VARYING4 * clamp(VARYING3.z * pow(VARYING3.x, 3.0), 0.0, 1.0)) + vec3(pow(clamp(VARYING3.y, 0.0, 1.0), 12.0) * VARYING3.w)) * f24) * CB0[10].xyz)) * CB0[15].y, vec3(0.0), vec3(1.0))), vec3(clamp(VARYING0.w, 0.0, 1.0))), 1.0);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
