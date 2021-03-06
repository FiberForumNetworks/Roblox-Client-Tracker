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
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D DiffuseMapTexture;

varying vec2 VARYING0;
varying vec4 VARYING2;
varying vec3 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;

void main()
{
    vec4 f0 = texture2D(DiffuseMapTexture, VARYING0);
    vec3 f1 = (mix(vec3(1.0), VARYING2.xyz, vec3(f0.w)) * f0.xyz).xyz;
    float f2 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f3 = VARYING3.yzx - (VARYING3.yzx * f2);
    vec4 f4 = vec4(clamp(f2, 0.0, 1.0));
    vec4 f5 = mix(texture3D(LightMapTexture, f3), vec4(0.0), f4);
    vec4 f6 = mix(texture3D(LightGridSkylightTexture, f3), vec4(1.0), f4);
    vec4 f7 = texture2D(ShadowMapTexture, VARYING6.xy);
    float f8 = (1.0 - ((step(f7.x, VARYING6.z) * clamp(CB0[24].z + (CB0[24].w * abs(VARYING6.z - 0.5)), 0.0, 1.0)) * f7.y)) * f6.y;
    vec3 f9 = ((min((f5.xyz * (f5.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f6.x)), vec3(CB0[16].w)) + (VARYING5.xyz * f8)) * (f1 * f1).xyz) + (CB0[10].xyz * (VARYING5.w * f8));
    vec4 f10 = vec4(f9.x, f9.y, f9.z, vec4(0.0).w);
    f10.w = VARYING2.w;
    vec3 f11 = mix(CB0[14].xyz, sqrt(clamp(f10.xyz * CB0[15].y, vec3(0.0), vec3(1.0))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    gl_FragData[0] = vec4(f11.x, f11.y, f11.z, f10.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$DiffuseMapTexture=s3
